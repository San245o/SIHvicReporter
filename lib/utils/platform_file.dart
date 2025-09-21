import 'dart:io' if (dart.library.html) './placeholder.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// This file will either import dart:io.File (for mobile)
// or the placeholder File (for web).

typedef PlatformFile = File;

// Helper functions for platform-agnostic file handling
class PlatformFileHelper {
  static bool get isWeb => kIsWeb;
  
  static PlatformFile fromPath(String path) {
    return PlatformFile(path);
  }
  
  // Helper method to create appropriate image widget based on platform
  static Widget buildImageWidget(PlatformFile file, {
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
  }) {
    if (kIsWeb) {
      return Image.network(
        file.path,
        fit: fit,
        width: width,
        height: height,
      );
    } else {
      try {
        return Image.file(
          file as dynamic, // Cast to dynamic to avoid compile-time type checking
          fit: fit,
          width: width,
          height: height,
        );
      } catch (e) {
        // Fallback for platforms where Image.file doesn't work
        return Container(
          width: width,
          height: height,
          color: Colors.grey.shade300,
          child: const Center(
            child: Icon(
              Icons.image,
              color: Colors.grey,
              size: 48,
            ),
          ),
        );
      }
    }
  }
}