import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/services/house_service.dart';
import 'package:myapp/src/services/image_upload_service.dart';
import 'package:myapp/src/models/house.dart';

class EditHouseDialog extends StatefulWidget {
  final House house;

  const EditHouseDialog({super.key, required this.house});

  @override
  State<EditHouseDialog> createState() => _EditHouseDialogState();
}

class _EditHouseDialogState extends State<EditHouseDialog> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  final _formKey = GlobalKey<FormState>();
  String? _imageUrl;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.house.name);
    _addressController = TextEditingController(text: widget.house.address);
    _imageUrl = widget.house.imageUrl; // Initialize with current image
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.edit, color: colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Edit House'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit house properties. Rooms cannot be modified from here.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'House Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a house name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'House Image',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _isUploadingImage ? null : _uploadImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outline.withOpacity(0.3), width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: colorScheme.surfaceVariant.withOpacity(0.3),
                ),
                child: _isUploadingImage
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : _imageUrl != null && _imageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  _imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildImagePlaceholder(theme, colorScheme);
                                  },
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _buildImagePlaceholder(theme, colorScheme),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap image to change',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'House Information',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Rooms:', style: theme.textTheme.bodySmall),
                      Text('${widget.house.totalRooms}', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Occupied Rooms:', style: theme.textTheme.bodySmall),
                      Text('${widget.house.occupiedRooms}', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Price:', style: theme.textTheme.bodySmall),
                      Text(widget.house.price, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          child: const Text('Save Changes'),
        ),
      ],
    );
  }

  Future<void> _uploadImage() async {
    try {
      final imageFile = await ImageUploadService.pickImageWithSource(context);
      if (imageFile == null) return;

      setState(() {
        _isUploadingImage = true;
      });

      // Upload with the house ID
      final downloadUrl = await ImageUploadService.uploadHouseImage(
        imageFile: File(imageFile.path),
        houseId: widget.house.id,
      );

      if (downloadUrl != null && mounted) {
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
            const SnackBar(content: Text('Failed to upload photo. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading photo: $e')),
        );
      }
    }
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final houseService = Provider.of<HouseService>(context, listen: false);
      
      houseService.updateHouse(
        houseId: widget.house.id,
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        imageUrl: _imageUrl, // Pass the image URL (will keep existing if unchanged)
      );

      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('House updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildImagePlaceholder(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate, size: 48, color: colorScheme.onSurfaceVariant),
        const SizedBox(height: 8),
        Text(
          'Tap to add photo',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

