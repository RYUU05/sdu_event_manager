import 'package:auto_route/auto_route.dart';
import 'package:event_manager/features/auth/presentation/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc_simple.dart';

@RoutePage()
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailCtrl = TextEditingController();
  final _emailFocus = FocusNode();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _send() {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _showSnack('Введите email', isError: true);
      return;
    }
    if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(email)) {
      _showSnack('Введите корректный email', isError: true);
      return;
    }
    context.read<AuthBloc>().add(ResetPasswordRequested(email));
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Восстановление пароля')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is PasswordResetSent) {
            _showSnack('Письмо отправлено! Проверьте почту.');
            context.router.maybePop();
          } else if (state is AuthError) {
            _showSnack(state.message, isError: true);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Введите email, привязанный к аккаунту. Мы отправим ссылку для сброса пароля.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 32),
              CustonTextField(
                controller: _emailCtrl,
                focusNode: _emailFocus,
                label: 'Email',
                icon: Icons.email_outlined,
                textInputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final loading = state is AuthLoading;
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: loading ? null : _send,
                      icon: loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_outlined),
                      label: const Text('Отправить письмо'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
