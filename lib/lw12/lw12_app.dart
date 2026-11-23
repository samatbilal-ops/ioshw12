import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth/auth_cubit.dart';
import 'cart/cart_bloc.dart';
import 'screens/login_screen.dart';

/// Standalone LW12 app: `flutter run -t lib/main_lw12.dart`.
/// Blocs are provided ABOVE MaterialApp so every route can reach them.
class Lw12App extends StatelessWidget {
  const Lw12App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => AuthCubit()),
        BlocProvider<CartBloc>(create: (_) => CartBloc()),
      ],
      child: MaterialApp(
        title: 'SoleStore BLoC',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepOrange),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
