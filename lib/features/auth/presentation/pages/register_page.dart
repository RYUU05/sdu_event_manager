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
  // Student fields
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  // Club field
  final clubNameCtrl = TextEditingController();

  bool _isClub = false;
  bool _isLoading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    clubNameCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;

    if (email.isEmpty) {
      showError('Введите email');
      return false;
    }
    if (pass.length <= 8) {
      showError('Пароль должен содержать более 8 символов');
      return false;
    }

    if (_isClub) {
      if (clubNameCtrl.text.trim().isEmpty) {
        showError('Введите название клуба');
        return false;
      }
    } else {
      if (firstNameCtrl.text.trim().isEmpty || lastNameCtrl.text.trim().isEmpty) {
        showError('Введите имя и фамилию');
        return false;
      }
    }
    return true;
  }

  Future<void> _register() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text,
      );

      final Map<String, dynamic> userData = {
        'email': emailCtrl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (_isClub) {
        userData['role'] = 'club';
        userData['name'] = clubNameCtrl.text.trim();
      } else {
        userData['role'] = 'student';
        final fullName = '${firstNameCtrl.text.trim()} ${lastNameCtrl.text.trim()}';
        userData['name'] = fullName;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set(userData);

      if (mounted) {
        context.router.push(const LoginRoute());
      }
    } on FirebaseAuthException catch (e) {
      showError(e.message ?? 'Ошибка регистрации');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Image(
              width: double.infinity,
              height: 160,
              image: AssetImage('assets/sdu_logo.png'),
            ),
            const SizedBox(height: 24),
            const Text(
              'SDU Events',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            // Role selector
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Студент'),
                  icon: Icon(Icons.school),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Клуб'),
                  icon: Icon(Icons.business),
                ),
              ],
              selected: {_isClub},
              onSelectionChanged: (set) =>
                  setState(() => _isClub = set.first),
            ),
            const SizedBox(height: 24),
            // Dynamic name fields based on role
            if (_isClub)
              CustonTextField(
                controller: clubNameCtrl,
                focusNode: FocusNode(),
                label: 'Название клуба',
                icon: Icons.business_center,
                textInputType: TextInputType.text,
              )
            else
              Column(
                children: [
                  CustonTextField(
                    controller: firstNameCtrl,
                    focusNode: FocusNode(),
                    label: 'Имя',
                    icon: Icons.person,
                    textInputType: TextInputType.name,
                  ),
                  const SizedBox(height: 12),
                  CustonTextField(
                    controller: lastNameCtrl,
                    focusNode: FocusNode(),
                    label: 'Фамилия',
                    icon: Icons.person_outline,
                    textInputType: TextInputType.name,
                  ),
                ],
              ),
            const SizedBox(height: 12),
            CustonTextField(
              controller: emailCtrl,
              focusNode: FocusNode(),
              label: 'Email',
              icon: Icons.email,
              textInputType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            CustonTextField(
              controller: passCtrl,
              focusNode: FocusNode(),
              label: 'Пароль (более 8 символов)',
              icon: Icons.lock,
              textInputType: TextInputType.visiblePassword,
              obscure: true,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _register,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(_isClub ? Icons.business : Icons.school),
                label: Text(
                  _isClub ? 'Зарегистрироваться как клуб' : 'Зарегистрироваться как студент',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Уже есть аккаунт?'),
                TextButton(
                  onPressed: () => context.router.push(const LoginRoute()),
                  child: const Text('Войти'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
