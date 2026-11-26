# LW13 орнату (бір рет жасалады)

## 1. Пакеттер
```
flutter pub add image_picker geolocator permission_handler path_provider
flutter pub get
```

## 2. Native рұқсаттар

**Автоматты:** `apply_lw13_permissions.ps1` файлын жоба түбіне (`pubspec.yaml` жатқан жерге) көшіріп:
```
powershell -ExecutionPolicy Bypass -File .\apply_lw13_permissions.ps1
```
Содан кейін екі файлды ашып, жолдар қосылғанын тексер.

**Қолмен.** `android/app/src/main/AndroidManifest.xml` ішінде `<application` тегінен **бұрын**:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
```

`ios/Runner/Info.plist` ішінде бірінші `<dict>` ішіне (соңғы `</dict>` алдына):
```xml
<key>NSCameraUsageDescription</key>
<string>Camera is used to capture photos for your geotagged diary.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Photo library access lets you pick existing pictures for your diary.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Your location is attached to each diary entry as a geotag.</string>
```

iOS (тек Mac-та): `ios/Podfile` ішіндегі `post_install` блогына `permission_handler` макросы керек:
```ruby
config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'PERMISSION_CAMERA=1', 'PERMISSION_PHOTOS=1']
```

## 3. Іске қосу
Android (Windows-та плагиндер үшін **Developer Mode** қосулы болу керек: `start ms-settings:developers`):
```
flutter devices
flutter run -d emulator-5554 -t lib/main_lw13.dart
```
(`emulator-5554` орнына `flutter devices` көрсеткен нақты id.)

Chrome-да да ашылады (`flutter run -d chrome -t lib/main_lw13.dart`): камера мен GPS браузерден рұқсат сұрайды. Бірақ Web-те файлдық жүйе жоқ, сондықтан фото беті жаңартылғанда сақталмайды. Қорғауда **Android эмуляторы не телефон** көрсет.

## 4. Эмуляторда GPS беру
Android Studio эмуляторында: `...` (Extended controls), **Location**, нүктені таңда не координата жазып **Send**. Камера үшін эмулятордың виртуалды камерасы жұмыс істейді (AVD Advanced Settings, Camera: VirtualScene).

## 5. Тесттер
```
flutter test
```
