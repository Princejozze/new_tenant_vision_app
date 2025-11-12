import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/src/models/tenant.dart';
import 'package:myapp/src/models/room.dart';
import 'package:myapp/src/services/image_upload_service.dart';

class NewTenantOnboardingDialog extends StatefulWidget {
  final Room room;
  final Function(Tenant) onTenantCreated;
  final Tenant? existingTenant; // For edit mode
  final bool isEditMode;

  const NewTenantOnboardingDialog({
    super.key,
    required this.room,
    required this.onTenantCreated,
    this.existingTenant,
    this.isEditMode = false,
  });

  @override
  State<NewTenantOnboardingDialog> createState() => _NewTenantOnboardingDialogState();
}

class _NewTenantOnboardingDialogState extends State<NewTenantOnboardingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _rentController = TextEditingController();
  
  DateTime? _startDate;
  String? _photoUrl;
  bool _areNameAndDateLocked = false;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.isEditMode && widget.existingTenant != null) {
      // Pre-populate fields for edit mode
      _firstNameController.text = widget.existingTenant!.firstName;
      _lastNameController.text = widget.existingTenant!.lastName;
      _emailController.text = widget.existingTenant!.email ?? '';
      _phoneController.text = widget.existingTenant!.phone ?? '';
      _jobTitleController.text = widget.existingTenant!.jobTitle ?? '';
      _rentController.text = widget.existingTenant!.monthlyRent.toString();
      _startDate = widget.existingTenant!.startDate;
      _photoUrl = widget.existingTenant!.photoUrl;
      
      // No locking - allow editing of all fields including name and date
      _areNameAndDateLocked = false;
    } else {
      // Default values for new tenant
      _rentController.text = '50000';
      _startDate = DateTime.now();
      // Don't lock for new tenants - allow them to be created freely
      _areNameAndDateLocked = false;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _jobTitleController.dispose();
    _rentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isEditMode ? 'Edit Tenant Information' : 'New Tenant Onboarding',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.isEditMode 
                          ? 'Update the tenant\'s personal and rent information.'
                          : 'Enter the new tenant\'s personal and rent information.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Form
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tenant Photo Section
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: colorScheme.surfaceVariant,
                            backgroundImage: _photoUrl != null 
                                ? NetworkImage(_photoUrl!) 
                                : null,
                            child: _photoUrl == null 
                                ? Icon(
                                    Icons.person,
                                    size: 40,
                                    color: colorScheme.onSurfaceVariant,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _isUploadingPhoto ? null : _uploadPhoto,
                            icon: _isUploadingPhoto
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.cloud_upload),
                            label: Text(_isUploadingPhoto ? 'Uploading...' : 'Upload Photo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.surfaceVariant,
                              foregroundColor: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Personal Information Section
                      Text(
                        'Personal Information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Column(
                        children: [
                          _buildTextField(
                            controller: _firstNameController,
                            label: 'First Name',
                            hintText: 'John',
                            enabled: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'First name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _lastNameController,
                            label: 'Last Name',
                            hintText: 'Doe',
                            enabled: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Last name is required';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _emailController,
                        label: 'Email (Optional)',
                        hintText: 'john.doe@example.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone (Optional)',
                        hintText: '0712345678',
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (value) {
                          if (value != null && value.isNotEmpty && value.length != 10) {
                            return 'Phone number must be exactly 10 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _jobTitleController,
                        label: 'Job Title (Optional)',
                        hintText: 'Software Engineer',
                      ),
                      const SizedBox(height: 32),

                      // Rent Information Section
                      Text(
                        'Rent Information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _rentController,
                        label: 'Monthly Rent Amount',
                        hintText: '50000',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Rent amount is required';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid rent amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Start Date Picker
                      InkWell(
                        onTap: _selectStartDate,
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: colorScheme.outline),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Start Date',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _startDate != null
                                            ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                            : 'Pick a date',
                                        style: theme.textTheme.bodyLarge,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_today,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saveTenant,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _uploadPhoto() async {
    try {
      final imageFile = await ImageUploadService.pickImageWithSource(context);
      if (imageFile == null) return;

      setState(() {
        _isUploadingPhoto = true;
      });

      // Upload to Firebase Storage
      final tenantId = widget.existingTenant?.id ?? 'temp-${DateTime.now().millisecondsSinceEpoch}';
      final downloadUrl = await ImageUploadService.uploadTenantImage(
        imageFile: File(imageFile.path),
        tenantId: tenantId,
      );

      if (downloadUrl != null && mounted) {
        setState(() {
          _photoUrl = downloadUrl;
          _isUploadingPhoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo uploaded successfully')),
        );
      } else {
        if (mounted) {
          setState(() {
            _isUploadingPhoto = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload photo. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading photo: $e')),
        );
      }
    }
  }

  void _selectStartDate() async {
    // Prevent selecting future dates - only allow past dates and today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? today,
      firstDate: DateTime(2000),
      lastDate: today, // Disable all future dates
      selectableDayPredicate: (DateTime date) {
        // Disable dates after today
        return !date.isAfter(today);
      },
    );
    
    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }

  void _saveTenant() {
    print('Save tenant button pressed - Edit mode: ${widget.isEditMode}');
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date')),
      );
      return;
    }

    print('Creating/updating tenant with data:');
    print('First Name: ${_firstNameController.text.trim()}');
    print('Last Name: ${_lastNameController.text.trim()}');
    print('Rent: ${_rentController.text}');

    final tenant = widget.isEditMode && widget.existingTenant != null
        ? widget.existingTenant!.updateInfo(
            // Always update all fields since there's no locking
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
            phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
            jobTitle: _jobTitleController.text.trim().isEmpty ? null : _jobTitleController.text.trim(),
            photoUrl: _photoUrl,
            monthlyRent: double.parse(_rentController.text),
            startDate: _startDate!,
          )
        : Tenant(
            id: 'tenant-${DateTime.now().millisecondsSinceEpoch}',
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
            phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
            jobTitle: _jobTitleController.text.trim().isEmpty ? null : _jobTitleController.text.trim(),
            photoUrl: _photoUrl,
            monthlyRent: double.parse(_rentController.text),
            startDate: _startDate!,
          );

    print('Tenant ${widget.isEditMode ? 'updated' : 'created'}: ${tenant.fullName} with rent ${tenant.monthlyRent}');
    widget.onTenantCreated(tenant);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tenant ${tenant.fullName} ${widget.isEditMode ? 'updated' : 'added'} successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    
    Navigator.of(context).pop();
  }
}
