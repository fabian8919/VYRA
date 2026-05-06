import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vyra/core/theme/app_theme.dart';

class CreatePostScreen extends StatefulWidget {
  final List<XFile>? initialImages;

  const CreatePostScreen({
    super.key,
    this.initialImages,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _descriptionController = TextEditingController();
  final PageController _pageController = PageController();
  
  List<XFile> _selectedImages = [];
  List<Uint8List> _imageBytes = [];
  int _currentImageIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialImages != null) {
      _selectedImages = widget.initialImages!;
      _loadImageBytes();
    }
  }

  Future<void> _loadImageBytes() async {
    if (kIsWeb) {
      final List<Uint8List> bytes = [];
      for (final image in _selectedImages) {
        final data = await image.readAsBytes();
        bytes.add(data);
      }
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        final XFile? photo = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
        if (photo != null) {
          setState(() {
            _selectedImages.add(photo);
          });
        }
      } else {
        final List<XFile> photos = await _picker.pickMultiImage(
          imageQuality: 85,
        );
        if (photos.isNotEmpty) {
          setState(() {
            _selectedImages.addAll(photos);
          });
          if (kIsWeb) {
            await _loadImageBytes();
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      if (kIsWeb && _imageBytes.isNotEmpty) {
        _imageBytes.removeAt(index);
      }
      if (_currentImageIndex >= _selectedImages.length && _currentImageIndex > 0) {
        _currentImageIndex--;
      }
    });
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Agregar foto',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
                ),
                SizedBox(height: 24),
                _ImageSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Cámara',
                  description: 'Toma una foto ahora',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                SizedBox(height: 12),
                _ImageSourceOption(
                  icon: Icons.photo_library,
                  label: 'Galería',
                  description: 'Elige de tu biblioteca',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _publishPost() async {
    if (_selectedImages.isEmpty) return;

    setState(() => _isLoading = true);

    // Simular publicación
    await Future.delayed(Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Publicación creada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppTheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Nueva publicación',
          style: TextStyle(
            color: AppTheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _selectedImages.isEmpty || _isLoading ? null : _publishPost,
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                    ),
                  )
                : Text(
                    'Compartir',
                    style: TextStyle(
                      color: _selectedImages.isEmpty
                          ? Colors.grey
                          : AppTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Área de imágenes
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Preview de imágenes
                  if (_selectedImages.isNotEmpty)
                    AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() => _currentImageIndex = index);
                            },
                            itemCount: _selectedImages.length,
                            itemBuilder: (context, index) {
                              if (kIsWeb) {
                                // En web usar Image.memory
                                if (_imageBytes.isNotEmpty && index < _imageBytes.length) {
                                  return Image.memory(
                                    _imageBytes[index],
                                    fit: BoxFit.cover,
                                  );
                                }
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              } else {
                                // En móvil/desktop usar Image.file
                                return Image.file(
                                  File(_selectedImages[index].path),
                                  fit: BoxFit.cover,
                                );
                              }
                            },
                          ),
                          // Contador de imágenes
                          if (_selectedImages.length > 1)
                            Positioned(
                              top: 16,
                              right: 16,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(153),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '${_currentImageIndex + 1}/${_selectedImages.length}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          // Botón eliminar imagen
                          Positioned(
                            top: 16,
                            left: 16,
                            child: GestureDetector(
                              onTap: () => _removeImage(_currentImageIndex),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(153),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    // Placeholder cuando no hay imágenes
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        color: Colors.grey.shade100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Selecciona una o más fotos',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Botón agregar más fotos
                  if (_selectedImages.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.outlineVariant),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: AppTheme.primaryBlue,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Agregar más fotos',
                                style: TextStyle(
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Sección de descripción
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Miniatura y usuario
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Center(
                          child: Text(
                            'A',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'andres_f',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurface,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Campo de descripción
                  TextField(
                    controller: _descriptionController,
                    maxLines: null,
                    minLines: 4,
                    maxLength: 2200,
                    decoration: InputDecoration(
                      hintText: 'Escribe una descripción...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      counterStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.onSurface,
                      height: 1.5,
                    ),
                  ),

                  Divider(height: 32),

                  // Opciones adicionales
                  _OptionRow(
                    icon: Icons.person_outline,
                    label: 'Etiquetar personas',
                    onTap: () {},
                  ),
                  _OptionRow(
                    icon: Icons.location_on_outlined,
                    label: 'Agregar ubicación',
                    onTap: () {},
                  ),
                  _OptionRow(
                    icon: Icons.music_note_outlined,
                    label: 'Agregar música',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: _selectedImages.isEmpty
          ? FloatingActionButton.extended(
              onPressed: _showImageSourceDialog,
              backgroundColor: AppTheme.primaryBlue,
              icon: Icon(Icons.add_photo_alternate),
              label: Text('Agregar foto'),
            )
          : null,
    );
  }
}

// ============================================================================
// WIDGETS AUXILIARES
// ============================================================================

class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  const _ImageSourceOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFFF0F0FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OptionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.onSurfaceVariant, size: 24),
            SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.onSurface,
              ),
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
