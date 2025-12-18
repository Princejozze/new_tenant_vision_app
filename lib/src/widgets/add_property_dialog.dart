import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/src/services/house_service.dart';
import 'package:myapp/src/services/image_upload_service.dart';
import 'package:provider/provider.dart';

class AddPropertyDialog extends StatefulWidget {
  const AddPropertyDialog({super.key});

  @override
  State<AddPropertyDialog> createState() => _AddPropertyDialogState();
}

class _AddPropertyDialogState extends State<AddPropertyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _roomsController = TextEditingController();
  String? _imageUrl;
  bool _isUploadingImage = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _roomsController.dispose();
    super.dispose();
  }

  Future<void> _uploadImage() async {
    try {
      final imageFile = await ImageUploadService.pickImageWithSource(context);
      if (imageFile == null) return;

      setState(() {
        _isUploadingImage = true;
      });

      // Generate a temporary house ID for the image path
      final tempHouseId = 'house-${DateTime.now().millisecondsSinceEpoch}';
      final downloadUrl = await ImageUploadService.uploadHouseImage(
        imageFile: File(imageFile.path),
        houseId: tempHouseId,
      );

      if (downloadUrl != null && downloadUrl.isNotEmpty && mounted) {
        setState(() {
          _imageUrl = downloadUrl;
          _isUploadingImage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo uploaded successfully')),
        );
      } else {
        if (mounted) {
          setState(() {
            _isUploadingImage = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload photo. Please ensure you are logged in and Firebase Storage rules are deployed. A default image will be used.'),
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Exception in house image upload: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
        String errorMessage = 'Error uploading photo';
        if (e.toString().contains('Permission') || e.toString().contains('unauthorized')) {
          errorMessage = 'Permission denied. Please ensure Firebase Storage rules are deployed in Firebase Console.';
        } else {
          errorMessage = 'Error: ${e.toString()}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _saveHouse() async {
    if (_formKey.currentState!.validate()) {
      final houseService = Provider.of<HouseService>(context, listen: false);
      
      final String houseName = _nameController.text;
      final String address = _addressController.text;
      final int numberOfRooms = int.parse(_roomsController.text);
      
      houseService.addHouse(
        name: houseName,
        address: address,
        numberOfRooms: numberOfRooms,
        imageUrl: _imageUrl, // Will use random if null
      );
      
      if (mounted) {
        Navigator.of(context).pop();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$houseName added successfully with $numberOfRooms rooms!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    final title = Text(
      'Add New House',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
    );

    final subtitle = Text(
      'Enter the details for your new rental property. Click save when you\'re done.',
      style: Theme.of(context).textTheme.bodyMedium,
    );

    final form = Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('House Name', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'e.g. Sunnyvale Villa',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a house name' : null,
          ),
          const SizedBox(height: 16),
          const Text('Address', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              hintText: '123 Main St, Anytown, USA',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Please enter an address' : null,
          ),
          const SizedBox(height: 16),
          const Text('Number of Rooms', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _roomsController,
            decoration: const InputDecoration(
              hintText: '1',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the number of rooms';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          const Text('House Image (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _isUploadingImage ? null : _uploadImage,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 2),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
              ),
              child: _isUploadingImage
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            _imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildImagePlaceholder();
                            },
                          ),
                        )
                      : _buildImagePlaceholder(),
            ),
          ),
          if (_imageUrl == null && !_isUploadingImage)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Tap to add photo. A default image will be used if none is selected.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
        ],
      ),
    );

    final actions = [
      TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
             backgroundColor: Theme.of(context).colorScheme.primary,
             foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        onPressed: _saveHouse,
        child: const Text('Save House'),
      ),
    ];

    if (isMobile) {
      return Material(
        child: Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    title,
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                subtitle,
                const SizedBox(height: 24),
                form,
                const SizedBox(height: 24),
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AlertDialog(
      title: title,
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            subtitle,
            const SizedBox(height: 24),
            form,
          ],
        ),
      ),
      actions: actions,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey.shade400),
        const SizedBox(height: 8),
        Text(
          'Tap to add photo',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      ],
    );
  }
}
