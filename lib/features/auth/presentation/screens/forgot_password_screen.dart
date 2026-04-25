import 'package:flutter/material.dart';
import 'package:vyra/core/theme/app_theme.dart';
import 'package:vyra/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.resetPassword(_emailController.text.trim());

      if (mounted) {
        setState(() => _emailSent = true);
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
              SizedBox(height: 20),

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

              SizedBox(height: 40),

              // Título
              Text(
                'Recuperar\ncontraseña',
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
                _emailSent
                    ? 'Revisa tu correo para continuar'
                    : 'Te enviaremos un enlace para restablecer tu contraseña',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 40),

              // Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: _emailSent
                    ? _buildSuccessContent()
                    : _buildFormContent(),
              ),

              SizedBox(height: 32),

              if (_emailSent)
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppTheme.buttonGradient,
                        borderRadius: BorderRadius.circular(27),
                        boxShadow: AppTheme.buttonShadow,
                      ),
                      child: Text(
                        'Volver al inicio',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
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

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Icono
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.lock_reset_outlined,
              color: AppTheme.primaryBlue,
              size: 40,
            ),
          ),

          SizedBox(height: 24),

          // Label
          _buildLabel('CORREO ELECTRÓNICO'),
          SizedBox(height: 8),

          // Input
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

          SizedBox(height: 28),

          // Botón
          GestureDetector(
            onTap: _isLoading ? null : _sendResetEmail,
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
                            'ENVIAR ENLACE',
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
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppTheme.buttonGradient,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF2563EB).withAlpha(60),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.mark_email_read_outlined,
            color: Colors.white,
            size: 48,
          ),
        ),

        SizedBox(height: 24),

        Text(
          '¡Correo enviado!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurface,
          ),
        ),

        SizedBox(height: 12),

        Text(
          'Revisa ${_emailController.text}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: AppTheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),

        SizedBox(height: 20),

        TextButton.icon(
          onPressed: _isLoading ? null : _sendResetEmail,
          icon: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryBlue,
                  ),
                )
              : Icon(Icons.refresh, size: 18),
          label: Text(
            _isLoading ? 'Enviando...' : 'Reenviar',
            style: TextStyle(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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
      ),
    );
  }
}
