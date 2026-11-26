# LW13: adds the native permissions to AndroidManifest.xml and Info.plist.
# Run from the Flutter project root (where pubspec.yaml is):
#   powershell -ExecutionPolicy Bypass -File .\apply_lw13_permissions.ps1
# Safe to run twice: it skips what is already there.

$utf8 = New-Object System.Text.UTF8Encoding $false

# ---------------- Android ----------------
$manifest = "android\app\src\main\AndroidManifest.xml"
if (Test-Path $manifest) {
  $path = (Resolve-Path $manifest).Path
  $text = [System.IO.File]::ReadAllText($path)
  if ($text.Contains("ACCESS_FINE_LOCATION")) {
    Write-Host "Android: permissions already present, skipped."
  } else {
    $perms = @'
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
    <uses-feature android:name="android.hardware.camera" android:required="false" />

'@
    $idx = $text.IndexOf("<application")
    if ($idx -ge 0) {
      $text = $text.Insert($idx, $perms.TrimEnd() + "`r`n`r`n    ")
      [System.IO.File]::WriteAllText($path, $text, $utf8)
      Write-Host "Android: permissions added."
    } else {
      Write-Host "Android: <application> tag not found, add the permissions by hand."
    }
  }
} else {
  Write-Host "Android: $manifest not found (run from the project root)."
}

# ---------------- iOS ----------------
$plist = "ios\Runner\Info.plist"
if (Test-Path $plist) {
  $path = (Resolve-Path $plist).Path
  $text = [System.IO.File]::ReadAllText($path)
  if ($text.Contains("NSCameraUsageDescription")) {
    Write-Host "iOS: keys already present, skipped."
  } else {
    $keys = @'
	<key>NSCameraUsageDescription</key>
	<string>Camera is used to capture photos for your geotagged diary.</string>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>Photo library access lets you pick existing pictures for your diary.</string>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>Your location is attached to each diary entry as a geotag.</string>

'@
    $idx = $text.LastIndexOf("</dict>")
    if ($idx -ge 0) {
      $text = $text.Insert($idx, $keys)
      [System.IO.File]::WriteAllText($path, $text, $utf8)
      Write-Host "iOS: keys added."
    } else {
      Write-Host "iOS: </dict> not found, add the keys by hand."
    }
  }
} else {
  Write-Host "iOS: $plist not found."
}
