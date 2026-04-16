import 'package:auto_route/auto_route.dart';
import 'package:event_manager/core/extensions/context_extensions.dart';
import 'package:event_manager/features/auth/domain/entities/user_entity.dart';
import 'package:event_manager/features/auth/presentation/bloc/auth_bloc_simple.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(name: 'CreateEventRoute')
class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedCategory;
  
  final List<String> _categories = [
    'Academic',
    'Sports',
    'Culture',
    'Social',
    'Career',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select date and time'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // TODO: Submit to backend
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event created: ${_titleController.text}'),
          backgroundColor: Colors.green,
        ),
      );
      
      context.router.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // Guard: Only club users can access
        if (authState is! Authenticated || authState.user.role != UserRole.club) {
          return Scaffold(
            appBar: AppBar(title: const Text('Access Denied')),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Only clubs can create events',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                ],
              ),
            ),
          );
        }

        final user = authState.user;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Create Event'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Club info card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.corporate_fare, color: Colors.purple),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Creating as:',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                user.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Event title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Event Title',
                      prefixIcon: Icon(Icons.event),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter event title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Category dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedCategory = value),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Location
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date & Time pickers
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
                      const SizedBox(width: 12),
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

                  // Submit button
                  ElevatedButton.icon(
                    onPressed: _submitForm,
                    icon: const Icon(Icons.add_circle),
                    label: const Text('Create Event'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
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
