import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_manager/features/auth/domain/entities/user_entity.dart';
import 'package:event_manager/features/auth/presentation/bloc/auth_bloc_simple.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:event_manager/features/home/domain/entities/event.dart';

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
    'Academic',
    'Sports',
    'Culture',
    'Social',
    'Career',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.eventToEdit != null) {
      final e = widget.eventToEdit!;
      _titleController.text = e.title;
      _descriptionController.text = e.description;
      _locationController.text = e.location;
      _maxParticipantsController.text = e.maxParticipants > 0 ? e.maxParticipants.toString() : '';
      _existingImageUrl = e.imageUrl;
      _selectedDate = e.date;
      _selectedTime = TimeOfDay.fromDateTime(e.date);
      if (_categories.contains(e.tags.isNotEmpty ? e.tags.first : 'Other')) {
        _selectedCategory = e.tags.first;
      } else {
        _selectedCategory = 'Other';
      }
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
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select date and time')));
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
        final ref = FirebaseStorage.instance.ref().child('events').child('${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(_selectedImage!);
        finalImageUrl = await ref.getDownloadURL();
      }

      final eventData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'imageUrl': finalImageUrl,
        'category': _selectedCategory,
        'maxParticipants': int.tryParse(_maxParticipantsController.text) ?? 0,
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
            const SnackBar(content: Text('Event updated!')),
          );
          context.router.maybePop();
        }
      } else {
        eventData['createdAt'] = FieldValue.serverTimestamp();
        eventData['currentParticipants'] = 0;
        eventData['participants'] = [];
        
        await FirebaseFirestore.instance.collection('events').add(eventData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event created!')),
          );
          context.router.maybePop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.eventToEdit != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Event' : 'Create Event')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! Authenticated || state.user.role != UserRole.club) {
            return const Center(child: Text('Only clubs can create events'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_selectedImage!, fit: BoxFit.cover),
                            )
                          : _existingImageUrl != null && _existingImageUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(_existingImageUrl!, fit: BoxFit.cover),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('Tap to add poster/image', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _maxParticipantsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max Participants (0 for unlimited)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v),
                    validator: (v) => v == null ? 'Select category' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectDate,
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            _selectedDate == null
                                ? 'Select Date'
                                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectTime,
                          icon: const Icon(Icons.access_time),
                          label: Text(
                            _selectedTime == null
                                ? 'Select Time'
                                : '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submitForm,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(isEditing ? Icons.save : Icons.add),
                      label: Text(
                        _isLoading
                            ? (isEditing ? 'Saving...' : 'Creating...')
                            : (isEditing ? 'Save Event' : 'Create Event'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
