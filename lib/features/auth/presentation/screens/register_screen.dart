import 'package:flutter/material.dart';
import 'package:vyra/core/theme/app_theme.dart';
import 'package:vyra/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _acceptTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      _showErrorSnackBar('Acepta los términos para continuar');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(245),
            borderRadius: BorderRadius.circular(28),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppTheme.buttonGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppTheme.buttonShadow,
                ),
                child: Icon(Icons.check, color: Colors.white, size: 40),
              ),
              SizedBox(height: 24),
              Text(
                '¡Bienvenido a Vyra!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Tu cuenta está lista. Comienza a descubrir imágenes increíbles.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 28),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppTheme.buttonGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.buttonShadow,
                  ),
                  child: Center(
                    child: Text(
                      'Comenzar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12),

              // Botón volver
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.outlineVariant, width: 1),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: AppTheme.onSurfaceVariant,
                    size: 18,
                  ),
                ),
              ),

              SizedBox(height: 32),

              // Título
              Text(
                'Crea tu\ncuenta',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Únete a la comunidad de creadores visuales.',
                style: TextStyle(fontSize: 16, color: AppTheme.onSurfaceVariant),
              ),

              SizedBox(height: 32),

              // Formulario
              Container(
                padding: EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre
                      _buildLabel('NOMBRE DE USUARIO'),
                      SizedBox(height: 8),
                      _buildTextField(
                        controller: _nameController,
                        hintText: 'Tu nombre',
                        keyboardType: TextInputType.name,
                        prefixIcon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa tu nombre';
                          }
                          if (value.length < 2) {
                            return 'Nombre muy corto';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 20),

                      // Email
                      _buildLabel('CORREO ELECTRÓNICO'),
                      SizedBox(height: 8),
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'tu@ejemplo.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa tu correo';
                          }
                          if (!value.contains('@')) {
                            return 'Correo inválido';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 20),

                      // Contraseña
                      _buildLabel('CONTRASEÑA'),
                      SizedBox(height: 8),
                      _buildTextField(
                        controller: _passwordController,
                        hintText: '••••••••',
                        obscureText: _obscurePassword,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        onSuffixTap: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa contraseña';
                          }
                          if (value.length < 6) {
                            return 'Mínimo 6 caracteres';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 20),

                      // Confirmar contraseña
                      _buildLabel('CONFIRMAR CONTRASEÑA'),
                      SizedBox(height: 8),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        hintText: '••••••••',
                        obscureText: _obscureConfirmPassword,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        onSuffixTap: () {
                          setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          );
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirma contraseña';
                          }
                          if (value != _passwordController.text) {
                            return 'No coinciden';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 20),

                      // Términos
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _acceptTerms = !_acceptTerms;
                              });
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _acceptTerms
                                    ? AppTheme.primaryBlue
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _acceptTerms
                                      ? AppTheme.primaryBlue
                                      : AppTheme.outlineVariant,
                                  width: 2,
                                ),
                              ),
                              child: _acceptTerms
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : null,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                text: 'Acepto los ',
                                style: TextStyle(
                                  color: AppTheme.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Términos',
                                    style: TextStyle(
                                      color: AppTheme.primaryBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' y ',
                                    style: TextStyle(
                                      color: AppTheme.onSurfaceVariant,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Privacidad',
                                    style: TextStyle(
                                      color: AppTheme.primaryBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 28),

                      // Botón crear cuenta
                      GestureDetector(
                        onTap: _isLoading ? null : _register,
                        child: Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: AppTheme.buttonGradient,
                            borderRadius: BorderRadius.circular(27),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF2563EB).withAlpha(60),
                                blurRadius: 16,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _isLoading
                                ? SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'CREAR CUENTA',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Login link
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '¿Ya tienes cuenta? ',
                      style: TextStyle(
                        color: AppTheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        'Entrar',
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppTheme.onSurfaceVariant,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(fontSize: 15, color: AppTheme.onSurface),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppTheme.outline.withAlpha(150), fontSize: 15),
        filled: true,
        fillColor: AppTheme.surfaceContainerLowest,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFB41340), width: 1),
        ),
        prefixIcon: Icon(prefixIcon, color: AppTheme.outline, size: 20),
        suffixIcon: suffixIcon != null
            ? GestureDetector(
                onTap: onSuffixTap,
                child: Icon(suffixIcon, color: AppTheme.outline.withAlpha(180), size: 20),
              )
            : null,
      ),
    );
  }
}
