import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth/auth_cubit.dart';
import '../auth/auth_state.dart';
import 'catalog_screen.dart';

/// Screen 1. BlocConsumer = BlocListener + BlocBuilder in one widget:
///   listener -> one-time side effects (SnackBar, navigation)
///   builder  -> pure rendering of the current state
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().login(_emailCtrl.text, _passwordCtrl.text);
  }

  void _fillDemo() {
    _emailCtrl.text = AuthCubit.demoEmail;
    _passwordCtrl.text = AuthCubit.demoPassword;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: BlocConsumer<AuthCubit, AuthState>(
                // ---------- side effects: run once per state change ----------
                listener: (context, state) {
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                  } else if (state is AuthSuccess) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => const CatalogScreen(),
                      ),
                    );
                  }
                },
                // ---------- UI only: no navigation / SnackBar here ----------
                builder: (context, state) {
                  final loading = state is AuthLoading;
                  return Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(Icons.shield_outlined,
                            size: 64, color: theme.colorScheme.primary),
                        const SizedBox(height: 12),
                        Text(
                          'Welcome back',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sign in to SoleStore',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: theme.hintColor),
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          key: const Key('lw12_email_field'),
                          controller: _emailCtrl,
                          enabled: !loading,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            if (value.isEmpty) return 'Enter your email';
                            if (!value.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          key: const Key('lw12_password_field'),
                          controller: _passwordCtrl,
                          enabled: !loading,
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              tooltip:
                                  _obscure ? 'Show password' : 'Hide password',
                              icon: Icon(_obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Enter your password'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 52,
                          child: loading
                              // button is REPLACED by a spinner while loading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    key: Key('lw12_login_spinner'),
                                  ),
                                )
                              : FilledButton(
                                  key: const Key('lw12_login_button'),
                                  onPressed: _submit,
                                  child: const Text('Login'),
                                ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: loading ? null : _fillDemo,
                          child: const Text(
                            'Use demo account\n'
                            '${AuthCubit.demoEmail} / ${AuthCubit.demoPassword}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
