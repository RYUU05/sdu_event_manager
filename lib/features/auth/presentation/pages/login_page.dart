import 'package:auto_route/auto_route.dart';
import 'package:event_manager/features/auth/presentation/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/router/app_router.gr.dart';
import '../bloc/auth_bloc_simple.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(email);
  }

  void _login() {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    if (email.isEmpty || pass.isEmpty) {
      _showError('Введите email и пароль');
      return;
    }
    if (!_isValidEmail(email)) {
      _showError('Введите корректный email');
      return;
    }
    if (pass.length < 6) {
      _showError('Пароль должен содержать минимум 6 символов');
      return;
    }

    context.read<AuthBloc>().add(LoginRequested(email, pass));
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  String _friendlyError(String raw) {
    if (raw.contains('wrong-password') || raw.contains('invalid-credential')) {
      return 'Неверный email или пароль';
    }
    if (raw.contains('user-not-found')) return 'Пользователь не найден';
    if (raw.contains('too-many-requests')) {
      return 'Слишком много попыток. Попробуйте позже';
    }
    if (raw.contains('network-request-failed')) return 'Нет подключения к сети';
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.router.replace(const AppShellRoute());
          } else if (state is AuthError) {
            _showError(_friendlyError(state.message));
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                Image.asset('assets/sdu_logo.png', width: double.infinity, height: 160),
                const SizedBox(height: 24),
                Text(
                  'SDU Events',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Добро пожаловать',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 40),
                CustonTextField(
                  controller: _emailCtrl,
                  focusNode: _emailFocus,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  textInputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CustonTextField(
                  controller: _passCtrl,
                  focusNode: _passFocus,
                  label: 'Пароль',
                  icon: Icons.lock_outline,
                  textInputType: TextInputType.visiblePassword,
                  obscure: true,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        context.router.push(const ForgotPasswordRoute()),
                    child: const Text('Забыли пароль?'),
                  ),
                ),
                const SizedBox(height: 16),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final loading = state is AuthLoading;
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: loading ? null : _login,
                        child: loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Войти',
                                style: TextStyle(fontSize: 16)),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Нет аккаунта?',
                        style:
                            TextStyle(color: Colors.grey[600])),
                    TextButton(
                      onPressed: () =>
                          context.router.push(const RegisterRoute()),
                      child: const Text('Зарегистрироваться'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
