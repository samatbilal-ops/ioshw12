import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/note_item.dart';
import '../providers/theme_controller.dart';
import '../services/vault_storage.dart';

/// Lab 11: Offline-First Notes & Settings Vault (single screen).
class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  late final VaultStorage _storage;
  final _nameCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  late String _displayName;
  late List<NoteItem> _notes;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _storage = context.read<VaultStorage>();
    // Synchronous reads: the prefs instance was prepared in main().
    _displayName = _storage.userName;
    _notes = _storage.loadNotes();
    if (_displayName != VaultStorage.defaultName) {
      _nameCtrl.text = _displayName;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  String _now() {
    final d = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.day} ${_months[d.month - 1]} ${d.year}, '
        '${two(d.hour)}:${two(d.minute)}';
  }

  void _toast(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _saveName() async {
    final value = _nameCtrl.text.trim();
    if (value.isEmpty) {
      _toast('Enter a username first');
      return;
    }
    await _storage.setUserName(value);
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    setState(() => _displayName = value);
    _toast('Username saved');
  }

  Future<void> _addNote() async {
    final title = _noteCtrl.text.trim();
    if (title.isEmpty) return;
    final note = NoteItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      dateText: _now(),
    );
    setState(() => _notes = [note, ..._notes]); // prepend
    _noteCtrl.clear();
    await _storage.saveNotes(_notes);
  }

  Future<void> _toggleNote(NoteItem note, bool? value) async {
    setState(() {
      _notes = [
        for (final n in _notes)
          if (n.id == note.id) n.copyWith(isCompleted: value ?? false) else n,
      ];
    });
    await _storage.saveNotes(_notes);
  }

  Future<void> _deleteNote(NoteItem note) async {
    setState(() => _notes = _notes.where((n) => n.id != note.id).toList());
    await _storage.saveNotes(_notes);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeCtrl = context.watch<ThemeController>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ---- header: auto-loaded username ----
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                _displayName.isEmpty ? '?' : _displayName[0].toUpperCase(),
                style: theme.textTheme.titleLarge,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back,',
                      style: TextStyle(color: theme.hintColor)),
                  Text(
                    _displayName,
                    key: const Key('vault_header_name'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ---- dark mode ----
        Card(
          child: SwitchListTile(
            key: const Key('vault_dark_switch'),
            secondary: Icon(
                themeCtrl.isDark ? Icons.dark_mode : Icons.light_mode_outlined),
            title: const Text('Dark mode'),
            subtitle: const Text('Saved on this device'),
            value: themeCtrl.isDark,
            onChanged: themeCtrl.setDark,
          ),
        ),

        // ---- username ----
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('vault_name_field'),
                    controller: _nameCtrl,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _saveName(),
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  key: const Key('vault_name_save'),
                  onPressed: _saveName,
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),

        // ---- add note ----
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const Key('vault_note_field'),
                controller: _noteCtrl,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _addNote(),
                decoration: const InputDecoration(
                  labelText: 'New note',
                  prefixIcon: Icon(Icons.edit_note),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              key: const Key('vault_note_add'),
              onPressed: _addNote,
              icon: const Icon(Icons.add),
              tooltip: 'Add note',
            ),
          ],
        ),
        const SizedBox(height: 16),

        Text('My notes (${_notes.length})',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),

        if (_notes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                Icon(Icons.note_alt_outlined,
                    size: 48, color: theme.hintColor),
                const SizedBox(height: 8),
                Text('No notes yet. Add the first one!',
                    style: TextStyle(color: theme.hintColor)),
              ],
            ),
          )
        else
          for (final note in _notes)
            Card(
              key: ValueKey(note.id),
              child: CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: note.isCompleted,
                onChanged: (v) => _toggleNote(note, v),
                title: Text(
                  note.title,
                  style: TextStyle(
                    decoration:
                        note.isCompleted ? TextDecoration.lineThrough : null,
                    color: note.isCompleted ? theme.hintColor : null,
                  ),
                ),
                subtitle: Text(note.dateText),
                secondary: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                  onPressed: () => _deleteNote(note),
                ),
              ),
            ),
      ],
    );
  }
}
