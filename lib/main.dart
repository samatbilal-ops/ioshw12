import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocProvider;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lw12/auth/auth_cubit.dart';
import 'lw12/cart/cart_bloc.dart';
import 'providers/cart_provider.dart';
import 'screens/registration_screen.dart';
import 'vault/providers/theme_controller.dart';
import 'vault/services/vault_storage.dart';

Future<void> main() async {
  // Lab 11: Flutter engine must be ready before using plugins (SharedPreferences)
  // and BEFORE runApp(), so the saved theme is known at the very first frame
  // -> no white flash when the app opens in dark mode.
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final storage = VaultStorage(prefs);

  runApp(
    MultiProvider(
      providers: [
        // One CartProvider for the whole app: every screen below can read it.
        ChangeNotifierProvider(create: (_) => CartProvider()),
        // Lab 11: local storage + theme (pre-loaded above).
        Provider<VaultStorage>.value(value: storage),
        ChangeNotifierProvider(create: (_) => ThemeController(storage)),
        // Lab 12: BLoC / Cubit (opened from Profile -> "LW12").
        BlocProvider<AuthCubit>(create: (_) => AuthCubit()),
        BlocProvider<CartBloc>(create: (_) => CartBloc()),
      ],
      child: const MyApp(),
    ),
  );
}

/// On the web/desktop the mouse can drag lists too -> pull-to-refresh works in Chrome.
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoleStore',
      debugShowCheckedModeBanner: false,
      scrollBehavior: AppScrollBehavior(),
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepOrange),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepOrange,
        brightness: Brightness.dark,
      ),
      // Lab 11: persisted Dark Mode switch.
      themeMode: context.watch<ThemeController>().mode,
      // Flow: Registration (Lab 6) -> Root with tabs (Lab 7) -> Detail (Lab 5)
      // The Feed tab is the Smart Catalog (LW8); the Vault tab is LW11.
      home: const RegistrationScreen(),
    );
  }
}
