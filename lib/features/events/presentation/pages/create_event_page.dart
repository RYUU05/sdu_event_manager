import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_manager/features/auth/domain/entities/user_entity.dart';
import 'package:event_manager/features/auth/presentation/bloc/auth_bloc_simple.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:event_manager/core/extensions/context_extensions.dart';

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:event_manager/features/home/domain/entities/event.dart';
import '../../../../core/di/injection.dart';
import '../../../unibuddy/data/unibuddy_api.dart';

@RoutePage(name: 'CreateEventRoute')
class CreateEventPage extends StatefulWidget {
  final Event? eventToEdit;

  const CreateEventPage({super.key, this.eventToEdit});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxParticipantsController = TextEditingController();

  File? _selectedImage;
  String? _existingImageUrl;
  final ImagePicker _picker = ImagePicker();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedCategory;
  bool _isLoading = false;

  final List<String> _categories = [
    'Academic', 'Sports', 'Culture', 'Social', 'Career', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.eventToEdit != null) {
      final e = widget.eventToEdit!;
      _titleController.text = e.title;
      _descriptionController.text = e.description;
      _locationController.text = e.location;
      _maxParticipantsController.text =
          e.maxParticipants > 0 ? e.maxParticipants.toString() : '';
      _existingImageUrl = e.imageUrl;
      _selectedDate = e.date;
      _selectedTime = TimeOfDay.fromDateTime(e.date);
      _selectedCategory =
          _categories.contains(e.tags.isNotEmpty ? e.tags.first : null)
              ? e.tags.first
              : null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ??
          DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        setState(() => _selectedImage = File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.localization.imageError}: $e')),
        );
      }
    }
  }

  String _getCategoryName(BuildContext context, String category) {
    switch (category) {
      case 'Academic':
        return context.localization.catAcademic;
      case 'Sports':
        return context.localization.catSports;
      case 'Culture':
        return context.localization.catCulture;
      case 'Social':
        return context.localization.catSocial;
      case 'Career':
        return context.localization.catCareer;
      case 'Other':
        return context.localization.catOther;
      default:
        return category;
    }
  }

  Future<void> _submitForm() async {
    final l10n = context.localization;
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectDateTimePrompt)),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.localization.selectCategoryPrompt)),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    setState(() => _isLoading = true);

    try {
      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      String finalImageUrl = _existingImageUrl ?? '';

      if (_selectedImage != null) {
        if (!await _selectedImage!.exists()) {
          throw Exception('Файл изображения не найден.');
        }

        final fileName =
            'events/${authState.user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = FirebaseStorage.instance.ref().child(fileName);
        final bytes = await _selectedImage!.readAsBytes();
        final metadata = SettableMetadata(contentType: 'image/jpeg');
        final uploadTask = ref.putData(bytes, metadata);
        final snapshot = await uploadTask.whenComplete(() {});

        if (snapshot.state == TaskState.success) {
          finalImageUrl = await snapshot.ref.getDownloadURL();
        } else {
          throw Exception(
              'Upload failed. Check Firebase Storage rules.');
        }
      }

      // Default image if none provided
      if (finalImageUrl.isEmpty) {
        finalImageUrl =
            'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=800&q=80';
      }

      // Validate max participants
      final maxPart = int.tryParse(_maxParticipantsController.text) ?? 0;
      if (maxPart < 0) {
        throw Exception(l10n.cannotBeNegative);
      }

      final eventData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'imageUrl': finalImageUrl,
        'category': _selectedCategory,
        'maxParticipants': maxPart,
        'dateTime': Timestamp.fromDate(dateTime),
        'clubId': authState.user.id,
        'clubName': authState.user.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.eventToEdit != null) {
        await FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventToEdit!.id)
            .update(eventData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.eventUpdated)),
          );
          context.router.maybePop();
        }
      } else {
        eventData['createdAt'] = FieldValue.serverTimestamp();
        eventData['currentParticipants'] = 0;
        eventData['participants'] = <String>[];
        eventData['isActive'] = true;

        await FirebaseFirestore.instance.collection('events').add(eventData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.eventCreated)),
          );
          context.router.maybePop();
        }
      }

      // Вызываем синхронизацию с Python-бэкендом
      try {
        await getIt<UniBuddyApi>().sync();
      } catch (e) {
        // Log sync error silently or handle as needed
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorLabel}: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.eventToEdit != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? context.localization.editEvent : context.localization.createEvent),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! Authenticated || state.user.role != UserRole.club_admin) {
            return Center(
              child: Text(context.localization.onlyClubsCreate),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: context.localization.eventTitle,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? context.localization.requiredField : null,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: context.localization.description,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Location
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: context.localization.location,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? context.localization.requiredField : null,
                  ),
                  const SizedBox(height: 16),

                  // Image picker
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[350]!),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_selectedImage!,
                                  fit: BoxFit.cover),
                            )
                          : _existingImageUrl != null &&
                                  _existingImageUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(_existingImageUrl!,
                                      fit: BoxFit.cover),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate,
                                        size: 40, color: Colors.grey[400]),
                                    const SizedBox(height: 8),
                                    Text(
                                      context.localization.addPosterPrompt,
                                      style: TextStyle(color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Max participants — with validation
                  TextFormField(
                    controller: _maxParticipantsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: context.localization.maxParticipants,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      final n = int.tryParse(v);
                      if (n == null) return context.localization.enterInteger;
                      if (n < 0) return context.localization.cannotBeNegative;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Category
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: context.localization.categoryLabel,
                      border: const OutlineInputBorder(),
                    ),
                    items: _categories
                        .map((c) =>
                            DropdownMenuItem(value: c, child: Text(_getCategoryName(context, c))))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedCategory = v),
                    validator: (v) =>
                        v == null ? context.localization.selectCategoryPrompt : null,
                  ),
                  const SizedBox(height: 16),

                  // Date + Time pickers
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectDate,
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            _selectedDate == null
                                ? context.localization.selectDate
                                : '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectTime,
                          icon: const Icon(Icons.access_time),
                          label: Text(
                            _selectedTime == null
                                ? context.localization.selectTime
                                : '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: _isLoading ? null : _submitForm,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Icon(isEditing ? Icons.save : Icons.add),
                      label: Text(
                        _isLoading
                            ? (isEditing ? context.localization.saving : context.localization.creating)
                            : (isEditing ? context.localization.save : context.localization.createEvent),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
