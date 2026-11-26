# Lab 12: Enterprise Auth & Shopping Cart with BLoC, қорғау нұсқаулығы

## Іске қосу
```
flutter pub add flutter_bloc:^8.1.3 equatable:^2.0.5
flutter pub get
flutter run -d chrome -t lib/main_lw12.dart
```
(Не үлкен қосымшада: **Profile** табы -> **LW12: BLoC Shop**.)

## Демо реті (3 минут)
1. **Қате:** `wrong@mail.kz` / `111111` -> Login -> 2 секунд **спиннер** (түйме орнына) -> **қызыл floating SnackBar** "Invalid email or password".
2. **Сәтті:** "Use demo account" басу (`student@narxoz.kz` / `123456`) -> Login -> спиннер -> **Catalog** экраны ("Hi, Student").
3. Бірнеше өнімге **Add** басу -> AppBar-дағы **Badge** санауышы бірден өседі, түйме "Add (2)" болады.
4. Себет белгісін басу -> **Cart** экраны: тізім, `баға × саны = сома`, төменде **Total**.
5. Өнімді қоқыс белгісімен (не солға сырғытып) өшіру -> Total мен Badge бірден өзгереді.
6. Артқа қайту -> Catalog-тағы Badge дәл сондай сан (екі экран бір `CartBloc` оқиды).
7. **Clear All** -> растау диалогы -> себет бос ("Your cart is empty").
8. Catalog-та **Logout** -> `AuthInitial` -> Login экраны.

## Файл құрылымы (`lib/lw12`)
| Файл | Рөлі |
|---|---|
| `auth/auth_state.dart` | `AuthInitial`, `AuthLoading`, `AuthSuccess(username,email)`, `AuthError(message)`: `Equatable` |
| `auth/auth_cubit.dart` | `login()`: `emit(Loading)` -> delay -> `emit(Success/Error)` |
| `cart/cart_event.dart` | `AddProductEvent`, `RemoveProductEvent`, `ClearCartEvent` |
| `cart/cart_state.dart` | `CartState(items, totalPrice, count)`, `CartLine` |
| `cart/cart_bloc.dart` | `on<Event>` өңдеушілері |
| `screens/login_screen.dart` | `BlocConsumer` |
| `screens/catalog_screen.dart` | өнімдер + `BlocBuilder` (Badge, "Add" түймесі) |
| `screens/cart_screen.dart` | себет, өшіру, Total, Clear All |

## Ықтимал сұрақтар
**`BlocListener` пен `BlocBuilder` айырмашылығы?**
`BlocBuilder` күй өзгергенде **виджетті қайта салады** (`builder` таза UI қайтарады, ішінде SnackBar/навигация болмауы керек, себебі `build` көп рет шақырылуы мүмкін). `BlocListener` күй өзгергенде `listener`-ді **бір рет** орындайды және виджет қайтармайды: SnackBar, `Navigator.push`, диалог секілді side-effect үшін. `BlocConsumer` екеуін біріктіреді: `listener` + `builder`. Менде Login-да: listener -> қызыл SnackBar және Catalog-қа өту, builder -> түйме немесе спиннер.

**Equatable рөлі қандай?**
Dart-та әдепкіде екі объект тек сол жад адресі бірдей болса ғана тең. `Equatable` `props` тізімі бойынша **мәндер теңдігін** (`==`, `hashCode`) береді. Bloc/Cubit `emit` алдында жаңа күйді ескісімен `==` арқылы салыстырады: тең болса **эмиссия болмайды**, виджеттер қайта салынбайды. Equatable-сыз әр `emit` (мазмұны бірдей болса да) жаңа объект ретінде қайта салуды тудырар еді, не керісінше тестте `expect(state, AuthError('x'))` сәйкес келмес еді. Менде `AuthError` үшін `props => [message]`.

**Неге `AuthError` қатарынан екі рет шығады, `==` оны тоқтатпай ма?**
Қатарынан емес: арасында `AuthLoading` бар (Error -> Loading -> Error), сондықтан екі күй де эмиссияланады және SnackBar екінші қатеде де шығады.

**Cubit пен Bloc айырмашылығы?**
Cubit: күйді тікелей **әдіс** (`login()`) арқылы өзгертеді, `emit()` шақырады, оқиға (event) жоқ. Bloc: UI **event** жібереді (`add(Event)`), `on<Event>` өңдеуші оны күйге айналдырады: бұл әрекеттерді бақылау/трассировкалау оңай, күрделі логикаға ыңғайлы. Auth қарапайым (бір әдіс) -> Cubit. Себет бірнеше әрекет -> Bloc (спецификация бойынша).

**Неге `CartState` әр рет жаңа объект?**
Күй **өзгермейтін (immutable)**. Тізімді ішінен өзгертсек (`items.add`), Equatable ескі мен жаңаны бірдей санап, UI жаңармас еді. Сондықтан `CartState.fromItems(newList)` жаңа тізім мен қайта есептелген `totalPrice`/`count` береді.

**Badge екі экранда қалай синхронды?**
`CartBloc` `MaterialApp`-тан **жоғары** `BlocProvider` арқылы бір рет жасалады. Catalog пен Cart (әртүрлі route) `context.read<CartBloc>()`/`BlocBuilder` арқылы **бір объектіні** алады. `buildWhen: previous.count != current.count` Badge-ті тек сан өзгергенде ғана қайта салады.

**`context.read` пен `context.watch` / `BlocBuilder` қашан?**
`read`: бір рет алу, event жіберу (`onPressed` ішінде), қайта салуды тудырмайды. `watch`/`BlocBuilder`: күйді тыңдап, қайта салады. `build` ішінде `read` қолдансаңыз UI жаңармайды.

**`buildWhen` / `listenWhen` не үшін?**
Қайта салуды/тыңдауды шектеу: Catalog-та "Add" түймесі тек **сол өнімнің** саны өзгергенде ғана қайта салынады (`quantityOf(id)`), бүкіл тізім емес. Logout listener тек `AuthInitial` күйінде жұмыс істейді.

**Неге `await Future.delayed` кейін `isClosed` тексеремін?**
Пайдаланушы кідіріс кезінде экраннан шығып, Cubit жабылса, `emit` жабық Cubit-те `StateError` берер еді.

**`BlocProvider.value` мен `create` айырмашылығы?**
`create` блокты өзі жасайды және өзі `close()` етеді. `.value` бар блокты береді, жабуды басқармайды (жаңа route-қа бұрыннан бар блокты беру үшін).

**Қате/Loading күйінде қосарлана басуды қалай болдырмаймын?**
Cubit-те `if (state is AuthLoading) return;` және UI-да түйме спиннермен алмастырылады, өрістер `enabled: !loading`.
