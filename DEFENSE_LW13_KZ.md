# Lab 13: Geotagged Photo Diary, қорғау нұсқаулығы

## Демо реті (3 минут)
1. Қосымшаны аш: бос preview (камера белгісі), координаттар "—".
2. **Take Photo** -> камера рұқсатын сұрайды (Allow) -> суретке түсу -> preview-да фото шығады, **GPS автоматты** алынады (спиннер "Waiting for GPS lock…"), Latitude/Longitude/Accuracy/Timestamp толады.
3. **Pick Gallery** -> галереядан басқа сурет таңда -> preview ауысады.
4. **Fetch Current GPS Location** -> қайта алу.
5. Caption жазу -> **SAVE ENTRY TO DIARY** -> төменде thumbnail, caption, `43.2389° N, 76.8897° E`, уақыт бар жазба пайда болады. Жазбаны басса, үлкен фото ашылады.
6. **GPS өшіру** (Quick Settings) -> Fetch -> диалог "Turn on GPS" -> **Open location settings** (`Geolocator.openLocationSettings()`).
7. Қосымшаны жап-аш -> диарий жазбалары қалады (SharedPreferences JSON + фото файлы `documents/diary_photos`).

## Файл құрылымы (`lib/lw13`)
| Файл | Рөлі |
|---|---|
| `models/diary_entry.dart` | `DiaryEntry` + `toJson`/`fromJson` |
| `services/location_service.dart` | GPS логикасы: қызмет қосулы ма, рұқсат, `getCurrentPosition` |
| `services/diary_storage.dart` | тізімді бір JSON ретінде сақтау |
| `utils/formatters.dart` | координат, дәлдік, уақыт форматы |
| `widgets/diary_image.dart` | `Image.file(File(path))` |
| `screens/photo_diary_screen.dart` | бүкіл UI және камера/галерея/GPS ағыны |

## Негізгі қорғау сұрақтары

**1. iOS-та `NSCameraUsageDescription` не үшін міндетті?**
iOS камераға, микрофонға, геолокацияға, фотоға кіруден бұрын **не үшін керек екенін түсіндіретін мәтін** (purpose string) талап етеді. Ол `Info.plist`-те болмаса, қосымша камераға жүгінген сәтте **жүйе оны бірден жауып тастайды (crash)**, ал App Store-ға мұндай қосымша **қабылданбайды (reject)**. Мәтін рұқсат диалогында пайдаланушыға көрсетіледі ("Camera is used to capture photos..."). Фото кітапханасы мен геолокация үшін де сондай кілттер бар: `NSPhotoLibraryUsageDescription`, `NSLocationWhenInUseUsageDescription`.

**2. Android-та "Don't ask again" таңдалса не болады?**
Рұқсат **тұрақты түрде бас тартылған (permanently denied)** күйге өтеді. Одан кейін `request()` жүйелік диалогты **көрсетпейді**, бірден `denied` қайтарады (`shouldShowRequestPermissionRationale` = false). Бағдарлама тек пайдаланушыны **қосымша баптауларына** жібере алады: `openAppSettings()`. Менде: `status.isPermanentlyDenied` болса, "Camera access is blocked" диалогы шығады, "Open settings" батырмасы баптауларды ашады. Геолокацияда да солай: `LocationPermission.deniedForever` -> `Geolocator.openAppSettings()`.

## Қосымша сұрақтар

**Рұқсат пен қызметтің айырмашылығы?**
Рұқсат (permission): қосымшаға GPS-ті пайдалануға **рұқсат бар ма**. Қызмет (service): құрылғыдағы **GPS ауыстырғышы қосулы ма**. Екеуі де керек, сондықтан алдымен `isLocationServiceEnabled()`, содан кейін `checkPermission()`/`requestPermission()` тексеремін.

**Манифестте CAMERA жазылса, неге runtime-да да сұраймын?**
Android 6+ қауіпті рұқсаттарды runtime-да береді. Манифестте `CAMERA` жарияланса, `image_picker` камераны ашпас бұрын рұқсат берілген болуы керек, әйтпесе қате/жабылу болады. Сондықтан `permission_handler`-мен `Permission.camera.request()` шақырамын. Галерея үшін Android-та жүйелік Photo Picker рұқсатты қажет етпейді.

**`imageQuality: 80` және `maxWidth: 1080` не үшін?**
Камера фотосы 5-12 MB болуы мүмкін. `maxWidth: 1080` енін кішірейтеді, `imageQuality: 80` JPEG сығуын 80%-ға қояды. Файл бірнеше есе кішірейеді, жад пен диск үнемделеді, интерфейс баяулап қалмайды.

**Неге фотоны `getApplicationDocumentsDirectory` ішіне көшіремін?**
`image_picker` суретті уақытша (cache) папкаға салады, оны жүйе кез келген уақытта тазалай алады. Диарий "offline" болуы үшін файлды қосымшаның тұрақты папкасына көшіріп, тек **жолын** JSON-да сақтаймын.

**`Image.file` пен `Image.network` айырмашылығы?**
`Image.file(File(path))` құрылғының файлдық жүйесіндегі суретті оқиды. `Image.network` URL бойынша жүктейді. Web-те файлдық жүйе жоқ, сондықтан Web-те `Image.network` (blob URL) қолданамын.

**`cacheWidth: 160` не береді?**
Thumbnail-ды үлкен көлемде декодтамай, 160 px-ке кішірейтіп жадқа жүктейді. Тізімде көп фото болса, жад үнемделеді.

**`LocationAccuracy.high` пен `desiredAccuracy`?**
Бұл GPS дәлдік деңгейі: `high` спутниктен дәл координат алады (батареяны көбірек жейді), `low`/`medium` жуық, жылдам және үнемді. Geolocator-дың жаңа нұсқаларында `desiredAccuracy` параметрі `LocationSettings(accuracy: ...)` ішіне көшкен, мағынасы бірдей.

**GPS accuracy ± 12.4 m не білдіреді?**
Нақты орын көрсетілген нүктеден шамамен 12.4 метр радиус ішінде жатыр (сенімділік шеңбері). Саны кіші болса, дәлірек.

**Спиннер қалай жұмыс істейді?**
`_fetchingGps` бул-ы `true` болады, `setState` UI-ды қайта салады (түйме мен карточкада `CircularProgressIndicator`), `finally` ішінде `false` қайтады. Қате болса да спиннер қалып қоймайды.

**Қате болғанда қосымша неге құламайды?**
Барлық GPS жолы `try/catch`-та: `LocationException` типтері (`serviceDisabled`, `denied`, `deniedForever`, `unavailable`) бөлек өңделеді, әрқайсысына SnackBar не диалог бар.
