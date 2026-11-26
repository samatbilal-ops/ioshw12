import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/diary_entry.dart';
import '../services/diary_storage.dart';
import '../services/location_service.dart';
import '../utils/formatters.dart';
import '../widgets/diary_image.dart';

/// LW13: Narxoz Geotagged Photo Diary (single screen).
class PhotoDiaryScreen extends StatefulWidget {
  const PhotoDiaryScreen({super.key});

  @override
  State<PhotoDiaryScreen> createState() => _PhotoDiaryScreenState();
}

class _PhotoDiaryScreenState extends State<PhotoDiaryScreen> {
  final _picker = ImagePicker();
  final _location = LocationService();
  final _captionCtrl = TextEditingController();

  DiaryStorage? _storage;
  List<DiaryEntry> _entries = [];

  // current (unsaved) moment
  String? _photoPath;
  Position? _position;
  DateTime? _timestamp;

  bool _loadingPhoto = false;
  bool _fetchingGps = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final storage = DiaryStorage(prefs);
    setState(() {
      _storage = storage;
      _entries = storage.load();
    });
  }

  // ------------------------------------------------------------------ UI utils

  void _toast(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ));
  }

  Future<void> _dialog({
    required String title,
    required String message,
    required String actionLabel,
    required Future<void> Function() onAction,
  }) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.info_outline),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await onAction();
            },
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ camera/gallery

  /// Runtime permission for the camera (Android + iOS).
  /// Needed because the camera permission is DECLARED in the manifest:
  /// Android refuses to open the camera until the user has granted it.
  Future<bool> _ensureCameraPermission() async {
    if (kIsWeb) return true; // the browser asks by itself

    var status = await Permission.camera.status;
    if (status.isGranted || status.isLimited) return true;

    status = await Permission.camera.request();
    if (status.isGranted || status.isLimited) return true;

    if (status.isPermanentlyDenied || status.isRestricted) {
      // "Don't ask again": the system dialog will never show up again,
      // the only way is the app settings screen.
      await _dialog(
        title: 'Camera access is blocked',
        message: 'Camera permission was denied permanently. '
            'Open the app settings and allow Camera to take photos.',
        actionLabel: 'Open settings',
        onAction: () async {
          await openAppSettings();
        },
      );
    } else {
      _toast('Camera permission is required to take a photo.');
    }
    return false;
  }

  Future<void> _pickPhoto(ImageSource source) async {
    if (_loadingPhoto) return;
    if (source == ImageSource.camera && !await _ensureCameraPermission()) {
      return;
    }

    setState(() => _loadingPhoto = true);
    var gotPhoto = false;
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 80, // JPEG compression
        maxWidth: 1080, // downscale big camera photos
      );
      if (picked != null) {
        // image_picker already stored the (compressed) photo as a file;
        // we keep its path in the diary entry.
        final stored = picked.path;
        if (!mounted) return;
        setState(() {
          _photoPath = stored;
          _timestamp = DateTime.now();
          _position = null; // coordinates belong to the previous photo
        });
        gotPhoto = true;
      }
    } on PlatformException catch (e) {
      _toast('Could not open the '
          '${source == ImageSource.camera ? 'camera' : 'gallery'}: '
          '${e.message ?? e.code}');
    } catch (e) {
      _toast('Something went wrong: $e');
    } finally {
      if (mounted) setState(() => _loadingPhoto = false);
    }

    // Automatically fetch the GPS position right after a new photo.
    if (gotPhoto) await _fetchLocation();
  }

  // ------------------------------------------------------------------- GPS

  Future<void> _fetchLocation() async {
    if (_fetchingGps) return;
    setState(() => _fetchingGps = true);
    try {
      final position = await _location.currentPosition();
      if (!mounted) return;
      setState(() {
        _position = position;
        _timestamp = DateTime.now();
      });
    } on LocationException catch (e) {
      await _handleLocationIssue(e);
    } catch (e) {
      _toast('Unexpected GPS error: $e');
    } finally {
      if (mounted) setState(() => _fetchingGps = false);
    }
  }

  Future<void> _handleLocationIssue(LocationException e) async {
    switch (e.issue) {
      case LocationIssue.serviceDisabled:
        await _dialog(
          title: 'Turn on GPS',
          message: 'Location services are disabled on this device. '
              'Please enable GPS to geotag your photo.',
          actionLabel: 'Open location settings',
          onAction: () async {
            if (kIsWeb) {
              _toast('Enable location in your browser/OS settings.');
            } else {
              await Geolocator.openLocationSettings();
            }
          },
        );
      case LocationIssue.deniedForever:
        await _dialog(
          title: 'Location access is blocked',
          message: 'Location permission was denied permanently. '
              'Open the app settings and allow Location.',
          actionLabel: 'Open app settings',
          onAction: () async {
            if (kIsWeb) {
              _toast('Allow location for this site in the browser.');
            } else {
              await Geolocator.openAppSettings();
            }
          },
        );
      case LocationIssue.denied:
      case LocationIssue.unavailable:
        _toast(e.message);
    }
  }

  // ------------------------------------------------------------------- diary

  Future<void> _saveEntry() async {
    final storage = _storage;
    final photo = _photoPath;
    final pos = _position;

    if (storage == null) return;
    if (photo == null) {
      _toast('Take or pick a photo first.');
      return;
    }
    if (pos == null) {
      _toast('Fetch the GPS location first.');
      return;
    }

    final caption = _captionCtrl.text.trim();
    final now = DateTime.now();
    final entry = DiaryEntry(
      id: now.microsecondsSinceEpoch.toString(),
      photoPath: photo,
      timestamp: _timestamp ?? now,
      latitude: pos.latitude,
      longitude: pos.longitude,
      accuracy: pos.accuracy,
      altitude: pos.altitude,
      caption: caption.isEmpty ? 'Untitled moment' : caption,
    );

    setState(() {
      _entries = [entry, ..._entries]; // newest first
      _photoPath = null;
      _position = null;
      _timestamp = null;
      _captionCtrl.clear();
    });
    FocusScope.of(context).unfocus();
    await storage.save(_entries);
    _toast('Entry saved to the diary');
  }

  Future<void> _deleteEntry(DiaryEntry entry) async {
    final storage = _storage;
    setState(() => _entries = _entries.where((e) => e.id != entry.id).toList());
    await storage?.save(_entries);
    if (!kIsWeb) {
      try {
        final f = File(entry.photoPath);
        if (await f.exists()) await f.delete();
      } catch (_) {/* the photo file is not critical */}
    }
  }

  void _openEntry(DiaryEntry entry) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DiaryImage(path: entry.photoPath, height: 280),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.caption,
                        style: Theme.of(ctx)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(formatCoordinates(entry.latitude, entry.longitude)),
                    Text('Accuracy: ${formatAccuracy(entry.accuracy)}'),
                    Text('Altitude: ${entry.altitude.toStringAsFixed(1)} m'),
                    Text(formatTimestamp(entry.timestamp)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Narxoz Photo Journal'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildPreview(theme),
                const SizedBox(height: 12),
                _buildInfoCard(theme),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        key: const Key('lw13_take_photo'),
                        onPressed: _loadingPhoto
                            ? null
                            : () => _pickPhoto(ImageSource.camera),
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: const Text('Take Photo'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        key: const Key('lw13_pick_gallery'),
                        onPressed: _loadingPhoto
                            ? null
                            : () => _pickPhoto(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Pick Gallery'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  key: const Key('lw13_fetch_gps'),
                  onPressed: _fetchingGps ? null : _fetchLocation,
                  icon: _fetchingGps
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                  label: Text(_fetchingGps
                      ? 'Locating…'
                      : 'Fetch Current GPS Location'),
                ),
                const Divider(height: 32),
                TextField(
                  key: const Key('lw13_caption_field'),
                  controller: _captionCtrl,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Caption',
                    hintText: 'Campus Quad at Narxoz',
                    prefixIcon: Icon(Icons.edit_note),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    key: const Key('lw13_save_entry'),
                    onPressed: _saveEntry,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('SAVE ENTRY TO DIARY'),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Diary Entries (${_entries.length})',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (_entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Column(
                      children: [
                        Icon(Icons.auto_stories_outlined,
                            size: 48, color: theme.hintColor),
                        const SizedBox(height: 8),
                        Text('Your diary is empty. Capture the first moment!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: theme.hintColor)),
                      ],
                    ),
                  )
                else
                  for (final entry in _entries) _buildEntryTile(entry),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(ThemeData theme) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: theme.colorScheme.surfaceContainerHighest,
          child: _loadingPhoto
              ? const Center(child: CircularProgressIndicator())
              : _photoPath == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_camera_outlined,
                            size: 64, color: theme.hintColor),
                        const SizedBox(height: 8),
                        Text('No photo yet',
                            style: TextStyle(color: theme.hintColor)),
                      ],
                    )
                  : DiaryImage(
                      path: _photoPath!,
                      width: double.infinity,
                      height: double.infinity,
                    ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    final pos = _position;
    String value(String? v) => v ?? '—';

    Widget row(IconData icon, String label, String text) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('$label: ', style: TextStyle(color: theme.hintColor)),
              Expanded(
                child: Text(text,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_fetchingGps)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Text('Waiting for GPS lock…'),
                  ],
                ),
              ),
            row(Icons.place_outlined, 'Latitude',
                value(pos == null ? null : formatDegrees(pos.latitude))),
            row(Icons.place_outlined, 'Longitude',
                value(pos == null ? null : formatDegrees(pos.longitude))),
            row(Icons.gps_fixed, 'Accuracy',
                value(pos == null ? null : formatAccuracy(pos.accuracy))),
            row(
                Icons.terrain,
                'Altitude',
                value(pos == null
                    ? null
                    : '${pos.altitude.toStringAsFixed(1)} m')),
            row(Icons.schedule, 'Timestamp',
                value(_timestamp == null ? null : formatTimestamp(_timestamp!))),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryTile(DiaryEntry entry) {
    return Card(
      key: ValueKey(entry.id),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        onTap: () => _openEntry(entry),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: DiaryImage(
            path: entry.photoPath,
            width: 64,
            height: 64,
            cacheWidth: 160,
          ),
        ),
        title: Text(entry.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${formatCoordinates(entry.latitude, entry.longitude)}\n'
          '${formatTimestamp(entry.timestamp)}',
        ),
        isThreeLine: true,
        trailing: IconButton(
          tooltip: 'Delete',
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _deleteEntry(entry),
        ),
      ),
    );
  }
}
