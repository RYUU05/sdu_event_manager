import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
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
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 32),
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.router.push(const LoginRoute()),
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
