import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_manager/features/auth/presentation/widgets/custom_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/router/app_router.gr.dart';

@RoutePage()
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final passFocusNode = FocusNode();
  final emailFocusNode = FocusNode();

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    passFocusNode.dispose();
    emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> registerStudent() async {
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text,
        password: passCtrl.text,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
            'email': emailCtrl.text,
            'role': 'student',
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        context.router.push(const LoginRoute());
      }
    } on FirebaseAuthException catch (e) {
      showError(e.message ?? 'Error');
    }
  }

  Future<void> registerClub() async {
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text,
        password: passCtrl.text,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
            'email': emailCtrl.text,
            'role': 'club',
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        context.router.push(const LoginRoute());
      }
    } on FirebaseAuthException catch (e) {
      showError(e.message ?? 'Error');
    }
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
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
            const SizedBox(height: 32),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: registerStudent,
                  icon: const Icon(Icons.school),
                  label: const Text('Register as Student'),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: registerClub,
                  icon: const Icon(Icons.business),
                  label: const Text('Register as Club'),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an account?'),
                TextButton(
                  onPressed: () => context.router.push(const LoginRoute()),
                  child: const Text('Login'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
