import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_manager/core/router/app_router.gr.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

@RoutePage()
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final TextEditingController _email;
  late final TextEditingController _pass;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _pass = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 10),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset('assets/sdu_logo.png', height: 100, width: 100),
            SizedBox(height: 20),
            Text(
              'Create an Account',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Please fill this detail to create an account',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _email,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,

              decoration: InputDecoration(
                hint: Text('Email'),
                prefixIcon: Icon(Icons.alternate_email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _pass,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                hint: Text('Password'),
                prefixIcon: Icon(Icons.password),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            SizedBox(height: 50),
            // Register as Student
            ElevatedButton.icon(
              onPressed: () async {
                final email = _email.text;
                final pass = _pass.text;
                try {
                  final userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                        email: email,
                        password: pass,
                      );
                  // Save user role to Firestore
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userCredential.user!.uid)
                      .set({
                        'email': email,
                        'role': 'student',
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                  debugPrint(
                    'Student registered: ${userCredential.user?.email}',
                  );
                  if (mounted) {
                    context.router.push(const LoginRoute());
                  }
                } on FirebaseAuthException catch (e) {
                  if (mounted) _handleAuthError(e);
                }
              },
              icon: const Icon(Icons.school),
              label: const Text(
                'Register as Student',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueAccent,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Register as Club
            ElevatedButton.icon(
              onPressed: () async {
                final email = _email.text;
                final pass = _pass.text;
                try {
                  final userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                        email: email,
                        password: pass,
                      );
                  // Save user role to Firestore
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userCredential.user!.uid)
                      .set({
                        'email': email,
                        'role': 'club',
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                  debugPrint('Club registered: ${userCredential.user?.email}');
                  if (mounted) {
                    context.router.push(const LoginRoute());
                  }
                } on FirebaseAuthException catch (e) {
                  if (mounted) _handleAuthError(e);
                }
              },
              icon: const Icon(Icons.corporate_fare),
              label: const Text(
                'Register as Club',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.purple,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account?"),
                TextButton(
                  onPressed: () {
                    context.router.push(const LoginRoute());
                  },
                  child: Text('Log in'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleAuthError(FirebaseAuthException e) {
    if (!mounted) return;
    String message = 'Registration failed';
    if (e.code == 'weak-password') {
      message = 'Password is too weak';
    } else if (e.code == 'email-already-in-use') {
      message = 'Email already in use';
    } else if (e.code == 'invalid-email') {
      message = 'Invalid email format';
    }
    debugPrint(message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
