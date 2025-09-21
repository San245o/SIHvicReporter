import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/platform_file.dart'; // Cross-platform File handling
import '../models/post.dart';
import '../providers/posts_provider.dart';
import '../providers/auth_provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';

class CreatePostPage extends ConsumerStatefulWidget {
  const CreatePostPage({super.key});
  
  @override
  ConsumerState<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _areaController = TextEditingController();
  
  String _selectedCategory = '';
  String _selectedSeverity = 'Medium';
  double _severityValue = 1.0; // 0 = Low, 1 = Medium, 2 = High
  final List<PlatformFile> _selectedImages = [];
  double _latitude = 12.9716; // Default Bangalore coordinates
  double _longitude = 77.5946;
  bool _isLoading = false;
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _areaController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final postsNotifier = ref.read(postsProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
       
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitPost,
            child: const Text('Post'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category Selection
              _buildCategorySection(),
              
              const SizedBox(height: 24),
              
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Brief description of the issue',
                  border: OutlineInputBorder(),
                ),
                maxLength: AppConstants.maxPostTitleLength,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  if (value.length < 10) {
                    return 'Title must be at least 10 characters';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Detailed description of the issue',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                maxLength: AppConstants.maxPostDescriptionLength,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  if (value.length < 20) {
                    return 'Description must be at least 20 characters';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Severity Section
              _buildSeveritySection(),
              
              const SizedBox(height: 24),
              
              // Location Section
              _buildLocationSection(),
              
              const SizedBox(height: 24),
              
              // Images Section
              _buildImagesSection(),
              
              const SizedBox(height: 32),
              
              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Submit Report',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.categories.map((category) {
            final isSelected = _selectedCategory == category;
            return FilterChip(
              label: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.black : Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              backgroundColor: Theme.of(context).cardColor,
              selectedColor: AppTheme.secondaryColor,
              checkmarkColor: Colors.black,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? category : '';
                });
              },
            );
          }).toList(),
        ),
        if (_selectedCategory.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Please select a category',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light 
                    ? AppTheme.lightErrorColor 
                    : AppTheme.errorColor, 
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildSeveritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Severity: $_selectedSeverity',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.secondaryColor,
              inactiveTrackColor: Theme.of(context).dividerColor,
              thumbColor: AppTheme.secondaryColor,
              overlayColor: AppTheme.secondaryColor.withOpacity(0.2),
              valueIndicatorColor: AppTheme.secondaryColor,
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Slider(
              value: _severityValue,
              min: 0,
              max: 2,
              divisions: 2,
              label: _selectedSeverity,
              onChanged: (value) {
                setState(() {
                  _severityValue = value;
                  _selectedSeverity = AppConstants.severityLevels[value.round()];
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: AppConstants.severityLevels.map((severity) {
            final index = AppConstants.severityLevels.indexOf(severity);
            final isSelected = _selectedSeverity == severity;
            return Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.getSeverityColor(severity) : Theme.of(context).dividerColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppTheme.getSeverityColor(severity) : Theme.of(context).dividerColor,
                      width: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  severity,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? AppTheme.getSeverityColor(severity) : Theme.of(context).textTheme.bodySmall?.color,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Area',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // Area Field
        TextFormField(
          controller: _areaController,
          decoration: const InputDecoration(
            labelText: 'Area',
            hintText: 'e.g., Koramangala 4th Block',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on, color: AppTheme.secondaryColor),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the area';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Location Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.my_location, 
                      color: AppTheme.secondaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Current Location',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _getCurrentLocation,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.secondaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text(
                      'Update',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.gps_fixed,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Lat: ${_latitude.toStringAsFixed(4)}, Lng: ${_longitude.toStringAsFixed(4)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Images (${_selectedImages.length}/${AppConstants.maxImagesPerPost})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // Image Grid
        if (_selectedImages.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _selectedImages.length + (_selectedImages.length < AppConstants.maxImagesPerPost ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _selectedImages.length) {
                return GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.light 
                          ? Colors.grey[200] 
                          : Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).dividerColor, style: BorderStyle.solid),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add_photo_alternate, 
                        size: 32, 
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                );
              }
              
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildImageDisplay(_selectedImages[index]),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.errorColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          )
        else
          GestureDetector(
            onTap: _pickImage,
            child:             Container(
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor, style: BorderStyle.solid),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate, 
                        size: 32, 
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Add Images',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        
        const SizedBox(height: 8),
        Text(
          'Add photos to help describe the issue. You can add up to ${AppConstants.maxImagesPerPost} images.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
  
  Future<void> _pickImage() async {
    if (_selectedImages.length >= AppConstants.maxImagesPerPost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only add up to ${AppConstants.maxImagesPerPost} images')),
      );
      return;
    }
    
    // Use await to ensure proper sequencing and prevent race conditions
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                // Return the source instead of calling Navigator.pop directly
                Navigator.of(context).pop(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                // Return the source instead of calling Navigator.pop directly
                Navigator.of(context).pop(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
    
    // Only proceed if a source was selected
    if (source != null) {
      await _pickImageFromSource(source);
    }
  }
  
Future<void> _pickImageFromSource(ImageSource source) async {
  try {
    // Request permission first
    if (source == ImageSource.camera) {
      // Request camera permission
      // For simplicity, using image_picker directly
    } else {
      // Request storage permission
      // For simplicity, using image_picker directly
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    
    if (image != null) {
      // Check file size - using XFile to avoid dart:io dependency
      final fileSize = await image.length();
      if (fileSize > AppConstants.maxImageSize) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image size too large. Please choose a smaller image.')),
        );
        return;
      }
      
      // Create a platform-agnostic file from the image path
      final file = PlatformFile(image.path);
      
      setState(() {
        _selectedImages.add(file);
      });
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to pick image: $e')),
    );
  }
}  
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }
  
  Widget _buildImageDisplay(PlatformFile file) {
    // Use our helper to handle platform differences
    return PlatformFileHelper.buildImageWidget(
      file,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
  
  Future<void> _getCurrentLocation() async {
    // TODO: Implement real location service
    // For now, use mock location
    setState(() {
      _latitude = 12.9716 + (DateTime.now().millisecondsSinceEpoch % 1000) / 100000;
      _longitude = 77.5946 + (DateTime.now().millisecondsSinceEpoch % 1000) / 100000;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location updated (mock)')),
    );
  }
  
  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // TODO: Upload images to server
      final imageUrls = <String>[];
      // Mock image upload for each selected image
      for (var i = 0; i < _selectedImages.length; i++) {
        // Mock image upload - in a real app, this would use the actual file
        imageUrls.add('assets/images/mock_${DateTime.now().millisecondsSinceEpoch}_$i.jpg');
      }
      
      final request = CreatePostRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        severity: _selectedSeverity,
        latitude: _latitude,
        longitude: _longitude,
        area: _areaController.text.trim(),
        images: imageUrls,
      );
      
      final postsNotifier = ref.read(postsProvider.notifier);
      final newPost = await postsNotifier.createPost(request);
      
      if (newPost != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully!')),
        );
        // Refresh posts list after creation
        await postsNotifier.refreshPosts();
        // Navigate to home instead of popping to avoid navigation issues
        context.go('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create post')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
