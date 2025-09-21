// This is a dummy class that mimics the dart:io.File API for web
class File {
  final String path;
  File(this.path);
  
  // Add common File methods used in your app
  bool existsSync() => true;
  
  // Add stub for length() to match dart:io File
  Future<int> length() async => 0;
  
  // Get the raw path for rendering in Image widgets
  String get rawPath => path;
}