import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class ImageUploadService {
  static final ImagePicker _picker = ImagePicker();
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  
  /// Check if user is authenticated
  static bool _isAuthenticated() {
    return FirebaseAuth.instance.currentUser != null;
  }

  /// Pick an image from gallery or camera
  static Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Show dialog to choose image source
  static Future<XFile?> pickImageWithSource(BuildContext context) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return null;
    return await pickImage(source: source);
  }

  /// Upload image to Firebase Storage and return download URL
  static Future<String?> uploadImage({
    required File imageFile,
    required String path,
    String? fileName,
  }) async {
    try {
      // Check authentication
      if (!_isAuthenticated()) {
        debugPrint('Error: User is not authenticated');
        return null;
      }
      
      final user = FirebaseAuth.instance.currentUser;
      debugPrint('Uploading as user: ${user?.uid}');
      
      // Check if file exists
      if (!await imageFile.exists()) {
        debugPrint('Error: Image file does not exist at path: ${imageFile.path}');
        return null;
      }
      
      final String finalFileName = fileName ?? '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('$path/$finalFileName');
      
      debugPrint('Uploading image to path: $path/$finalFileName');
      debugPrint('File size: ${await imageFile.length()} bytes');
      
      // Set metadata for the upload
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'max-age=31536000',
      );
      
      final UploadTask uploadTask = ref.putFile(imageFile, metadata);
      final TaskSnapshot snapshot = await uploadTask;
      
      if (snapshot.state == TaskState.success) {
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        debugPrint('Image uploaded successfully. URL: $downloadUrl');
        return downloadUrl;
      } else {
        debugPrint('Upload failed with state: ${snapshot.state}');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('Error uploading image to $path: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Check if it's a permissions error
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('permission') || 
          errorStr.contains('unauthorized') || 
          errorStr.contains('403') ||
          errorStr.contains('storage/unauthorized')) {
        debugPrint('PERMISSION ERROR: Firebase Storage rules may not be deployed. Please deploy storage.rules to Firebase Console.');
        throw Exception('Permission denied. Please ensure Firebase Storage rules are deployed and you are logged in.');
      }
      
      return null;
    }
  }

  /// Upload tenant image
  static Future<String?> uploadTenantImage({
    required File imageFile,
    required String tenantId,
  }) async {
    return await uploadImage(
      imageFile: imageFile,
      path: 'tenants',
      fileName: '$tenantId.jpg',
    );
  }

  /// Upload landlord profile image
  static Future<String?> uploadLandlordImage({
    required File imageFile,
    required String landlordId,
  }) async {
    return await uploadImage(
      imageFile: imageFile,
      path: 'landlords',
      fileName: '$landlordId.jpg',
    );
  }

  /// Upload house image
  static Future<String?> uploadHouseImage({
    required File imageFile,
    required String houseId,
  }) async {
    return await uploadImage(
      imageFile: imageFile,
      path: 'houses',
      fileName: '$houseId.jpg',
    );
  }

  /// Delete image from Firebase Storage
  static Future<bool> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }
}

