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
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;
  final emailFocusNode = FocusNode();
  final passFocusNode = FocusNode();

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    emailFocusNode.dispose();
    passFocusNode.dispose();
    super.dispose();
  }

  void login() {
    if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter email and password')));
      return;
    }

    setState(() => loading = true);
    context.read<AuthBloc>().add(LoginRequested(emailCtrl.text, passCtrl.text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.router.replace(const HomeRoute());
          } else if (state is AuthError) {
            setState(() => loading = false);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(
                width: double.infinity,
                height: 200,
                image: AssetImage('assets/sdu_logo.png'),
              ),
              const SizedBox(height: 50),
              const Text(
                'SDU Events',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              CustonTextField(
                controller: emailCtrl,
                focusNode: emailFocusNode,
                label: 'Email',
                icon: Icons.email,
                textInputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustonTextField(
                controller: passCtrl,
                focusNode: passFocusNode,
                label: 'Password',
                icon: Icons.lock,
                textInputType: TextInputType.visiblePassword,
                obscure: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: loading ? null : login,
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text('Login'),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Wanna join to our fun?'),
                  TextButton(
                    onPressed: () => context.router.push(const RegisterRoute()),
                    child: const Text('Create account'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
