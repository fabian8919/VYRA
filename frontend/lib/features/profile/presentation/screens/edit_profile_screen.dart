import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vyra/core/theme/app_theme.dart';
import 'package:vyra/services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _nickNameController = TextEditingController();
  late final TextEditingController _fullNameController = TextEditingController();
  late final TextEditingController _bioController = TextEditingController();

  XFile? _selectedImage;
  Uint8List? _webImageBytes;
  bool _isSaving = false;
  bool _isLoadingProfile = true;
  bool _avatarDeleted = false;

  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _authService.currentUser;
    if (user != null) {
      try {
        final profile = await _authService.getProfile(user.id);
        debugPrint('[EditProfile] profile loaded: $profile');
        if (mounted) {
          setState(() {
            final rawNick = profile?['username'] as String? ?? '';
            _nickNameController.text = rawNick.isEmpty
                ? '@'
                : (rawNick.startsWith('@') ? rawNick : '@$rawNick');
            _fullNameController.text = profile?['full_name'] as String? ?? '';
            _bioController.text = profile?['bio'] as String? ?? '';
            _currentAvatarUrl = profile?['avatar_url'] as String?;
            _isLoadingProfile = false;
          });
        }
      } catch (e) {
        debugPrint('[EditProfile] error loading profile: $e');
        if (mounted) {
          setState(() {
            _nickNameController.text = '@';
            _fullNameController.text = '';
            _bioController.text = '';
            _isLoadingProfile = false;
          });
        }
      }
    } else {
      setState(() => _isLoadingProfile = false);
    }
  }

  @override
  void dispose() {
    _nickNameController.dispose();
    _fullNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (photo != null) {
        if (kIsWeb) {
          final bytes = await photo.readAsBytes();
          setState(() {
            _selectedImage = photo;
            _webImageBytes = bytes;
          });
        } else {
          setState(() {
            _selectedImage = photo;
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
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
                  'Cambiar foto de perfil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 24),
                _buildSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Cámara',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                SizedBox(height: 12),
                _buildSourceOption(
                  icon: Icons.photo_library,
                  label: 'Galería',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_currentAvatarUrl != null || _selectedImage != null)
                  Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: _buildSourceOption(
                      icon: Icons.delete_outline,
                      label: 'Eliminar foto',
                      iconColor: Colors.red,
                      textColor: Colors.red,
                      onTap: () async {
                        Navigator.pop(context);
                        // Borrar del Storage inmediatamente para no dejar archivos huérfanos
                        if (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty) {
                          await _deleteAvatarFromStorage(_currentAvatarUrl);
                        }
                        setState(() {
                          _selectedImage = null;
                          _webImageBytes = null;
                          _currentAvatarUrl = null;
                          _avatarDeleted = true;
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? AppTheme.primaryBlue, size: 24),
            SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor ?? AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Extrae el path relativo dentro del bucket desde una URL pública de Supabase Storage.
  /// Ej: https://.../storage/v1/object/public/images/{userId}/{fileName}
  /// Devuelve: {userId}/{fileName}
  String? _extractStoragePath(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      // Busca el índice de 'images' y toma todo lo que viene después
      final imagesIndex = pathSegments.indexOf('images');
      if (imagesIndex == -1 || imagesIndex + 1 >= pathSegments.length) {
        return null;
      }
      return pathSegments.sublist(imagesIndex + 1).join('/');
    } catch (e) {
      return null;
    }
  }

  /// Borra un archivo del bucket 'images' dado su URL pública.
  Future<void> _deleteAvatarFromStorage(String? avatarUrl) async {
    if (avatarUrl == null || avatarUrl.isEmpty) return;
    final path = _extractStoragePath(avatarUrl);
    if (path == null) return;
    try {
      await Supabase.instance.client.storage.from('images').remove([path]);
    } catch (e) {
      debugPrint('Error eliminando avatar anterior: $e');
    }
  }

  Future<String?> _uploadAvatar() async {
    if (_selectedImage == null) return _currentAvatarUrl;

    final user = _authService.currentUser;
    if (user == null) return null;

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = user.id; // carpeta por usuario: images/{userId}/{fileName}

    final supabase = Supabase.instance.client;
    debugPrint('[Upload] user: ${user.id}, path: $filePath/$fileName');
    debugPrint('[Upload] session: ${supabase.auth.currentSession != null}');

    // 1. Borrar foto anterior si existe
    await _deleteAvatarFromStorage(_currentAvatarUrl);

    // 2. Subir nueva foto
    try {
      if (kIsWeb) {
        final bytes = _webImageBytes ?? await _selectedImage!.readAsBytes();
        await supabase.storage.from('images').uploadBinary(
          '$filePath/$fileName',
          bytes,
          fileOptions: FileOptions(contentType: 'image/jpeg'),
        );
      } else {
        await supabase.storage.from('images').upload(
          '$filePath/$fileName',
          File(_selectedImage!.path),
          fileOptions: FileOptions(contentType: 'image/jpeg'),
        );
      }
    } on StorageException catch (e) {
      debugPrint('[Upload] StorageException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[Upload] Error: $e');
      rethrow;
    }

    final url = supabase.storage.from('images').getPublicUrl('$filePath/$fileName');
    // Eliminar parámetros de query para URL limpia
    return Uri.parse(url).replace(queryParameters: {}).toString();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      String? avatarUrl;

      if (_selectedImage != null) {
        // Caso 1: nueva imagen seleccionada
        avatarUrl = await _uploadAvatar();
      } else if (_avatarDeleted) {
        // Caso 2: usuario eliminó su foto
        avatarUrl = null;
      } else {
        // Caso 3: sin cambios
        avatarUrl = _currentAvatarUrl;
      }

      await _authService.updateProfile(
        username: _nickNameController.text.trim(),
        bio: _bioController.text.trim(),
        avatarUrl: avatarUrl,
        fullName: _fullNameController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } on StorageException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al subir la imagen. Verifica que el bucket "images" exista en Supabase.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _getInitials() {
    final name = _fullNameController.text.trim();
    if (name.isNotEmpty) return name[0].toUpperCase();
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBlue),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.outlineVariant.withAlpha(100),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Editar perfil',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    children: [
                      // Avatar editable
                      GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                gradient: AppTheme.buttonGradient,
                                borderRadius: BorderRadius.circular(65),
                                border: Border.all(color: Colors.white, width: 4),
                                boxShadow: AppTheme.buttonShadow,
                              ),
                              child: ClipOval(
                                child: _buildAvatarImage(),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.buttonGradient,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF2563EB).withAlpha(100),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),
                      // Campo nickname (username)
                      _buildTextField(
                        controller: _nickNameController,
                        label: 'Username / Nickname',
                        hint: 'Tu apodo',
                        icon: Icons.alternate_email,
                        inputFormatters: [_AtPrefixFormatter()],
                        validator: (value) {
                          if (value == null || value.trim().length <= 1) {
                            return 'El username es obligatorio';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      // Campo nombre completo
                      _buildTextField(
                        controller: _fullNameController,
                        label: 'Nombre completo',
                        hint: 'Tu nombre real',
                        icon: Icons.person_outline,
                      ),
                      SizedBox(height: 20),
                      // Campo bio
                      _buildTextField(
                        controller: _bioController,
                        label: 'Descripción',
                        hint: 'Cuéntanos sobre ti...',
                        icon: Icons.edit_note,
                        maxLines: 4,
                        maxLength: 150,
                        textInputAction: TextInputAction.done,
                      ),
                      SizedBox(height: 32),
                      // Botón guardar
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: AppTheme.buttonGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: _isSaving ? [] : AppTheme.buttonShadow,
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: _isSaving
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      'Guardar cambios',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarImage() {
    if (_selectedImage != null) {
      if (kIsWeb && _webImageBytes != null) {
        return Image.memory(
          _webImageBytes!,
          fit: BoxFit.cover,
          width: 130,
          height: 130,
        );
      } else if (!kIsWeb) {
        return Image.file(
          File(_selectedImage!.path),
          fit: BoxFit.cover,
          width: 130,
          height: 130,
        );
      }
    }

    if (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty) {
      return Image.network(
        _currentAvatarUrl!,
        fit: BoxFit.cover,
        width: 130,
        height: 130,
        errorBuilder: (context, error, stackTrace) => _buildInitialsFallback(),
      );
    }

    return _buildInitialsFallback();
  }

  Widget _buildInitialsFallback() {
    return Container(
      color: Colors.transparent,
      alignment: Alignment.center,
      child: Text(
        _getInitials(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    Widget? prefix,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    int? maxLength,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          textInputAction: textInputAction ?? TextInputAction.next,
          validator: validator,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefix == null
                ? Icon(icon, color: AppTheme.textSecondary)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 12),
                      Icon(icon, color: AppTheme.textSecondary),
                      SizedBox(width: 8),
                      prefix,
                      SizedBox(width: 4),
                    ],
                  ),
            prefixIconConstraints: prefix != null
                ? BoxConstraints(minWidth: 0, minHeight: 0)
                : null,
          ),
        ),
      ],
    );
  }
}

class _AtPrefixFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return TextEditingValue(
        text: '@',
        selection: TextSelection.collapsed(offset: 1),
      );
    }

    if (!newValue.text.startsWith('@')) {
      final text = '@${newValue.text.replaceAll('@', '')}';
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(
          offset: newValue.selection.end + 1 - (newValue.text.length - newValue.text.replaceAll('@', '').length),
        ),
      );
    }

    return newValue;
  }
}
