import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:event_manager/core/extensions/context_extensions.dart';
import 'package:event_manager/features/auth/domain/entities/user_entity.dart';
import 'package:event_manager/features/auth/presentation/bloc/auth_bloc_simple.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  File? _newAvatar;
  File? _newBanner;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = (context.read<AuthBloc>().state as Authenticated).user;
    _nameCtrl = TextEditingController(text: user.name);
    _descCtrl = TextEditingController(text: user.description);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isAvatar) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() {
        if (isAvatar) {
          _newAvatar = File(picked.path);
        } else {
          _newBanner = File(picked.path);
        }
      });
    }
  }

  Future<String?> _uploadFile(File file, String folder, String userId) async {
    final ext = file.path.split('.').last;
    final ref = FirebaseStorage.instance.ref().child('$folder/$userId.$ext');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = (context.read<AuthBloc>().state as Authenticated).user;
      final repo = sl<AuthRepository>();

      String? newAvatarUrl;
      if (_newAvatar != null) {
        newAvatarUrl = await _uploadFile(_newAvatar!, 'avatars', user.id);
      }

      String? newBannerUrl;
      if (_newBanner != null) {
        newBannerUrl = await _uploadFile(_newBanner!, 'banners', user.id);
      }

      await repo.updateProfile(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        avatarUrl: newAvatarUrl,
        bannerUrl: newBannerUrl,
      );

      if (mounted) {
        context.read<AuthBloc>().add(RefreshProfileRequested());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.localization.profileUpdated)),
        );
        context.router.maybePop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.localization.errorLabel}: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) return const SizedBox.shrink();
        final user = state.user;

        return Scaffold(
          appBar: AppBar(
            title: Text(context.localization.editProfile),
            actions: [
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else
                IconButton(
                  onPressed: _save,
                  icon: const Icon(Icons.check),
                  tooltip: context.localization.saveChanges,
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Selection
                  if (user.role == UserRole.clubAdmin) ...[
                    Text(context.localization.banner, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _pickImage(false),
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          image: _newBanner != null
                              ? DecorationImage(image: FileImage(_newBanner!), fit: BoxFit.cover)
                              : user.bannerUrl.isNotEmpty
                                  ? DecorationImage(image: NetworkImage(user.bannerUrl), fit: BoxFit.cover)
                                  : null,
                        ),
                        child: (_newBanner == null && user.bannerUrl.isEmpty)
                            ? const Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Avatar Selection
                  Center(
                    child: Column(
                      children: [
                        Text(context.localization.avatar, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _pickImage(true),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _newAvatar != null
                                ? FileImage(_newAvatar!)
                                : user.avatarUrl.isNotEmpty
                                    ? NetworkImage(user.avatarUrl) as ImageProvider
                                    : null,
                            child: (_newAvatar == null && user.avatarUrl.isEmpty)
                                ? const Icon(Icons.person, size: 50, color: Colors.grey)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Name
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: context.localization.firstName,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? context.localization.requiredField : null,
                  ),
                  const SizedBox(height: 16),

                  // Description (Clubs only)
                  if (user.role == UserRole.clubAdmin) ...[
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: context.localization.clubDescription,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _save,
                      child: Text(context.localization.saveChanges),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
