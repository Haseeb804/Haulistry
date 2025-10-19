import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Utility class for handling image operations including Base64 conversion
class ImageUtils {
  /// Convert XFile image to Base64 data URL
  /// 
  /// This method reads the image bytes and encodes them as a Base64 string
  /// with the data URL prefix (data:image/jpeg;base64,...)
  /// 
  /// Args:
  ///   image: The XFile image from image_picker
  /// 
  /// Returns:
  ///   Base64 encoded data URL string
  static Future<String> convertImageToBase64(XFile image) async {
    try {
      // Read image bytes
      final bytes = await image.readAsBytes();
      
      // Determine MIME type from file extension
      String mimeType = 'image/jpeg'; // Default
      final extension = image.path.split('.').last.toLowerCase();
      
      if (extension == 'png') {
        mimeType = 'image/png';
      } else if (extension == 'jpg' || extension == 'jpeg') {
        mimeType = 'image/jpeg';
      } else if (extension == 'gif') {
        mimeType = 'image/gif';
      } else if (extension == 'webp') {
        mimeType = 'image/webp';
      }
      
      // Encode bytes to Base64
      final base64String = base64Encode(bytes);
      
      // Return data URL format
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      throw Exception('Failed to convert image to Base64: $e');
    }
  }
  
  /// Convert File to Base64 data URL
  /// 
  /// Args:
  ///   file: The File object
  /// 
  /// Returns:
  ///   Base64 encoded data URL string
  static Future<String> convertFileToBase64(File file) async {
    try {
      // Read file bytes
      final bytes = await file.readAsBytes();
      
      // Determine MIME type from file extension
      String mimeType = 'image/jpeg'; // Default
      final extension = file.path.split('.').last.toLowerCase();
      
      if (extension == 'png') {
        mimeType = 'image/png';
      } else if (extension == 'jpg' || extension == 'jpeg') {
        mimeType = 'image/jpeg';
      } else if (extension == 'gif') {
        mimeType = 'image/gif';
      } else if (extension == 'webp') {
        mimeType = 'image/webp';
      }
      
      // Encode bytes to Base64
      final base64String = base64Encode(bytes);
      
      // Return data URL format
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      throw Exception('Failed to convert file to Base64: $e');
    }
  }
  
  /// Create Image widget from Base64 data URL
  /// 
  /// This method decodes a Base64 data URL and creates a Flutter Image widget
  /// that can be displayed in the UI.
  /// 
  /// Args:
  ///   base64String: Base64 encoded data URL (data:image/jpeg;base64,...)
  ///   fit: How the image should fit within its bounds
  /// 
  /// Returns:
  ///   Image widget ready to display
  static Widget imageFromBase64(
    String base64String, {
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
  }) {
    try {
      // Remove data URL prefix if present
      String base64Data = base64String;
      if (base64String.contains(',')) {
        base64Data = base64String.split(',').last;
      }
      
      // Decode Base64 to bytes
      final bytes = base64Decode(base64Data);
      
      // Create Image widget from bytes
      return Image.memory(
        bytes,
        fit: fit,
        width: width,
        height: height,
      );
    } catch (e) {
      // Return error placeholder if decoding fails
      return Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(
            Icons.broken_image,
            color: Colors.grey,
            size: 48,
          ),
        ),
      );
    }
  }
  
  /// Get Uint8List bytes from Base64 data URL
  /// 
  /// Args:
  ///   base64String: Base64 encoded data URL
  /// 
  /// Returns:
  ///   Decoded bytes or null if invalid
  static Uint8List? decodeBase64Image(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return null;
    }
    
    try {
      // Remove data URL prefix if present
      String base64Data = base64String;
      if (base64String.contains(',')) {
        base64Data = base64String.split(',').last;
      }
      
      // Decode Base64 to bytes
      return base64Decode(base64Data);
    } catch (e) {
      print('Error decoding Base64 image: $e');
      return null;
    }
  }
  
  /// Get Uint8List bytes from Base64 data URL
  /// 
  /// Args:
  ///   base64String: Base64 encoded data URL
  /// 
  /// Returns:
  ///   Decoded bytes
  static Uint8List bytesFromBase64(String base64String) {
    try {
      // Remove data URL prefix if present
      String base64Data = base64String;
      if (base64String.contains(',')) {
        base64Data = base64String.split(',').last;
      }
      
      // Decode Base64 to bytes
      return base64Decode(base64Data);
    } catch (e) {
      throw Exception('Failed to decode Base64 string: $e');
    }
  }
  
  /// Check if a string is a valid Base64 data URL
  /// 
  /// Args:
  ///   str: String to validate
  /// 
  /// Returns:
  ///   true if valid Base64 data URL, false otherwise
  static bool isValidBase64DataUrl(String? str) {
    if (str == null || str.isEmpty) return false;
    
    // Check for data URL prefix
    if (!str.startsWith('data:image/')) return false;
    
    // Check for base64 indicator
    if (!str.contains('base64,')) return false;
    
    try {
      // Try to decode the base64 part
      final base64Data = str.split(',').last;
      base64Decode(base64Data);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Get file size estimate from Base64 string in KB
  /// 
  /// Base64 encoding increases size by approximately 33%.
  /// This method estimates the original file size.
  /// 
  /// Args:
  ///   base64String: Base64 encoded data URL
  /// 
  /// Returns:
  ///   Estimated file size in KB
  static double getBase64FileSizeKB(String base64String) {
    try {
      // Remove data URL prefix if present
      String base64Data = base64String;
      if (base64String.contains(',')) {
        base64Data = base64String.split(',').last;
      }
      
      // Calculate size in bytes (Base64 is ~33% larger than original)
      final base64SizeBytes = base64Data.length;
      final estimatedOriginalBytes = base64SizeBytes * 0.75;
      
      // Convert to KB
      return estimatedOriginalBytes / 1024;
    } catch (e) {
      return 0;
    }
  }
  
  /// Create a circular avatar from Base64 image
  /// 
  /// Args:
  ///   base64String: Base64 encoded data URL
  ///   radius: Radius of the circular avatar
  /// 
  /// Returns:
  ///   CircleAvatar widget
  static Widget circularAvatarFromBase64(
    String? base64String, {
    double radius = 40,
    Color backgroundColor = Colors.grey,
    IconData placeholderIcon = Icons.person,
  }) {
    if (base64String == null || !isValidBase64DataUrl(base64String)) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: Icon(
          placeholderIcon,
          size: radius * 0.8,
          color: Colors.white,
        ),
      );
    }
    
    try {
      final bytes = bytesFromBase64(base64String);
      return CircleAvatar(
        radius: radius,
        backgroundImage: MemoryImage(bytes),
        backgroundColor: backgroundColor,
      );
    } catch (e) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: Icon(
          Icons.broken_image,
          size: radius * 0.8,
          color: Colors.white,
        ),
      );
    }
  }
}
