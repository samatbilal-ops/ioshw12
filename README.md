# SoleStore (Lab 5-13)

Flow: **Registration (Lab 6)** -> **Root with 4 tabs (Lab 7)** -> detail screens.

| Tab | What it is |
|---|---|
| Feed | Smart Catalog (LW8): List/Grid, pull-to-refresh, swipe-to-delete + UNDO, empty state |
| Cloud | **Lab 10**: products from https://fakestoreapi.com/products |
| Favorites | saved sneakers |
| Profile | settings, log out |
| Profile -> LW12 | **Lab 12**: BLoC/Cubit shop (Login -> Catalog -> Cart) |
| Profile -> LW13 | **Lab 13**: Geotagged Photo Diary (camera, gallery, GPS) |
| Vault | **Lab 11**: offline notes + settings saved with SharedPreferences |

Global cart (Lab 9, Provider) is shared by Feed, Cloud and the Cart screen.

## Lab 10 - Cloud Product Explorer (`lib/explorer`)
- `models/product.dart`: `Product.fromJson` with `(json['price'] as num?)?.toDouble() ?? 0.0` and null-safe fallbacks
- `services/product_api.dart`: `http.get` + 10 s timeout + try/catch, handles 200 / 404 / 5xx / offline / bad JSON
- `screens/explorer_screen.dart`: 3 UI states (Loading, Feed, Error + "Retry Connection"), `RefreshIndicator`, `ListView.separated`, search + category chips
- `screens/product_detail_screen.dart`: `Hero(tag: 'product_image_${id}')`, photo carousel, share button, sticky "Add to Cart"
- `widgets/photo_carousel.dart`: `PageView.builder`, counter `1 / 3`, animated dots
- `widgets/share_sheet.dart`: bottom sheet with deep link `narxoz://store/product/{id}` + copy button
- Tests: `test/explorer_product_test.dart`, `test/explorer_api_test.dart`

## Lab 11 - Offline-First Notes & Settings Vault (`lib/vault`)
- `main.dart`: `WidgetsFlutterBinding.ensureInitialized()` + `await SharedPreferences.getInstance()` BEFORE `runApp()` -> theme is known at the first frame (no flicker)
- `services/vault_storage.dart`: keys `app_theme_dark_mode` (bool), `user_display_name` (String, fallback `'Guest User'`), notes list as ONE JSON string (`jsonEncode` / `jsonDecode`)
- `models/note_item.dart`: `NoteItem(id, title, dateText, isCompleted)` + `toJson()` / `factory fromJson()`
- `providers/theme_controller.dart`: Dark Mode state, saved on every change
- `screens/vault_screen.dart`: header with name, dark switch, username + Save, add (prepend) / toggle / delete notes, each change is written to disk
- Tests: `test/vault_storage_test.dart`

## Lab 12 - Enterprise Auth & Shopping Cart with BLoC (`lib/lw12`)
- `auth/auth_state.dart`: `AuthInitial`, `AuthLoading`, `AuthSuccess(username, email)`, `AuthError(message)` - all `Equatable`
- `auth/auth_cubit.dart`: `login(email, password)` -> `AuthLoading` -> 2 s simulated delay -> `AuthSuccess` / `AuthError` (demo: `student@narxoz.kz` / `123456`)
- `cart/cart_event.dart`: `AddProductEvent(Product)`, `RemoveProductEvent(productId)`, `ClearCartEvent()`
- `cart/cart_state.dart`: `CartState(items, totalPrice, count)` (Equatable, immutable)
- `cart/cart_bloc.dart`: `on<AddProductEvent>`, `on<RemoveProductEvent>`, `on<ClearCartEvent>`
- `screens/login_screen.dart`: `BlocConsumer` - listener: red floating SnackBar / navigation; builder: spinner instead of the button
- `screens/catalog_screen.dart`: product list + "Add" -> `AddProductEvent`, live badge via `BlocBuilder`
- `screens/cart_screen.dart`: lines, remove (button or swipe), total, "Clear All" with confirmation
- Tests: `test/lw12_bloc_test.dart`
- Run standalone: `flutter run -d chrome -t lib/main_lw12.dart` (or Profile tab -> "LW12: BLoC Shop")

## Lab 13 - Narxoz Geotagged Photo Diary (`lib/lw13`)
- `services/location_service.dart`: GPS on? -> permission (check/request) -> `getCurrentPosition(high)`; typed `LocationException`
- `screens/photo_diary_screen.dart`: Take Photo / Pick Gallery (`imageQuality: 80`, `maxWidth: 1080`), live preview with `Image.file`, GPS card with spinner, caption, Save, diary feed
- `models/diary_entry.dart` + `services/diary_storage.dart`: offline diary (JSON in SharedPreferences, photos copied to app documents)
- Native permissions: see `LW13_SETUP.md` (+ `apply_lw13_permissions.ps1`)
- Run: `flutter run -d <android-device> -t lib/main_lw13.dart`
- Tests: `test/lw13_diary_test.dart`

## Run
```
flutter pub add provider http shared_preferences:^2.2.2 flutter_bloc:^8.1.3 equatable:^2.0.5 image_picker geolocator permission_handler path_provider
flutter pub get
flutter run -d chrome
flutter test
```
