import 'package:auto_route/auto_route.dart';
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
            ElevatedButton(
              onPressed: () async {
                final email = _email.text;
                final pass = _pass.text;
                final router = context.router;
                try {
                  final userCreadential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                        email: email,
                        password: pass,
                      );
                  debugPrint(userCreadential.toString());
                  if (!mounted) return;
                  router.push(const LoginRoute());
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'weak-password') {
                    debugPrint('Weak password');
                  } else if (e.code == 'email-already-in-use') {
                    debugPrint('Email already in use');
                  } else if (e.code == 'invalid-email') {
                    debugPrint('Invalid email');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueAccent,
                minimumSize: Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Sign up', style: TextStyle(fontSize: 20)),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account?"),
                TextButton(
                  onPressed: () {
                    context.router.replace(const LoginRoute());
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
}
