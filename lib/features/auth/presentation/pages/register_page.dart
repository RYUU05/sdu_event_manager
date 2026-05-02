import 'package:auto_route/auto_route.dart';
import 'package:event_manager/features/auth/presentation/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:event_manager/core/extensions/context_extensions.dart';
import '../../domain/entities/user_entity.dart';
import '../../../../core/router/app_router.gr.dart';
import '../bloc/auth_bloc_simple.dart';

@RoutePage()
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _clubNameCtrl = TextEditingController();

  // FocusNodes stored as fields — properly disposed, no memory leaks
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _clubNameFocus = FocusNode();

  bool _isClub = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _clubNameCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _clubNameFocus.dispose();
    super.dispose();
  }

  bool _validate() {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    if (email.isEmpty) {
      _showError(context.localization.enterEmail);
      return false;
    }
    if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(email)) {
      _showError(context.localization.invalidEmail);
      return false;
    }
    if (pass.length < 8) {
      _showError(context.localization.shortPassword); // Note: I used 'shortPassword' but it says 8 in Russian text, I'll update the localization key text if needed
      return false;
    }

    if (_isClub) {
      if (_clubNameCtrl.text.trim().isEmpty) {
        _showError(context.localization.enterClubName);
        return false;
      }
    } else {
      if (_firstNameCtrl.text.trim().isEmpty ||
          _lastNameCtrl.text.trim().isEmpty) {
        _showError(context.localization.enterNameSurname);
        return false;
      }
    }
    return true;
  }

  void _register() {
    if (!_validate()) return;

    final name = _isClub
        ? _clubNameCtrl.text.trim()
        : '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}';

    // Use AuthBloc — consistent with login flow, no direct Firebase calls
    context.read<AuthBloc>().add(RegisterRequested(
          _emailCtrl.text.trim(),
          _passCtrl.text,
          name,
          _isClub ? UserRole.club : UserRole.student,
        ));
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // Auto-navigate — no need to re-login after registration
            context.router.replace(const AppShellRoute());
          } else if (state is AuthError) {
            _showError(state.message);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                Image.asset('assets/sdu_logo.png', width: double.infinity, height: 130),
                const SizedBox(height: 16),
                Text(
                  context.localization.register,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(
                      value: false,
                      label: Text(context.localization.student),
                      icon: const Icon(Icons.school_outlined),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text(context.localization.club),
                      icon: const Icon(Icons.groups_outlined),
                    ),
                  ],
                  selected: {_isClub},
                  onSelectionChanged: (set) =>
                      setState(() => _isClub = set.first),
                ),
                const SizedBox(height: 20),
                if (_isClub)
                  CustonTextField(
                    controller: _clubNameCtrl,
                    focusNode: _clubNameFocus,
                    label: context.localization.clubNameLabel,
                    icon: Icons.business_center_outlined,
                    textInputType: TextInputType.text,
                  )
                else
                  Column(
                    children: [
                      CustonTextField(
                        controller: _firstNameCtrl,
                        focusNode: _firstNameFocus,
                        label: context.localization.firstName,
                        icon: Icons.person_outlined,
                        textInputType: TextInputType.name,
                      ),
                      const SizedBox(height: 12),
                      CustonTextField(
                        controller: _lastNameCtrl,
                        focusNode: _lastNameFocus,
                        label: context.localization.lastName,
                        icon: Icons.person_outline,
                        textInputType: TextInputType.name,
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                CustonTextField(
                  controller: _emailCtrl,
                  focusNode: _emailFocus,
                  label: context.localization.email,
                  icon: Icons.email_outlined,
                  textInputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                CustonTextField(
                  controller: _passCtrl,
                  focusNode: _passFocus,
                  label: context.localization.password, // Minimum 8 characters logic is handled by validator/hint if needed
                  icon: Icons.lock_outline,
                  textInputType: TextInputType.visiblePassword,
                  obscure: true,
                ),
                const SizedBox(height: 24),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final loading = state is AuthLoading;
                    return SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: loading ? null : _register,
                        icon: loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Icon(_isClub ? Icons.groups : Icons.school),
                        label: Text(
                          _isClub
                              ? context.localization.registerAsClub
                              : context.localization.registerAsStudent,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(context.localization.haveAccount,
                        style: TextStyle(color: Colors.grey[600])),
                    TextButton(
                      onPressed: () =>
                          context.router.replace(const LoginRoute()),
                      child: Text(context.localization.login),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
