import 'package:flutter/material.dart';
import 'package:vyra/core/theme/app_theme.dart';
import 'package:vyra/services/auth_service.dart';

// Colores del nuevo diseño
class _ForgotColors {
  static const Color background = Color(0xFFF0F0FF);
  static const Color surfaceContainer = Color(0xFFE8E8FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF2563EB);
  static const Color onSurface = Color(0xFF292B51);
  static const Color onSurfaceVariant = Color(0xFF565881);
  static const Color outline = Color(0xFF71739E);
  static const Color outlineVariant = Color(0xFFC4C4E0);

  static const LinearGradient vibrantBlue = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
  );
}

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
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ForgotColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Botón volver
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _ForgotColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _ForgotColors.outlineVariant, width: 1),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: _ForgotColors.onSurfaceVariant,
                    size: 18,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Título
              const Text(
                'Recuperar\ncontraseña',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: _ForgotColors.onSurface,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _emailSent
                    ? 'Revisa tu correo para continuar'
                    : 'Te enviaremos un enlace para restablecer tu contraseña',
                style: TextStyle(
                  fontSize: 16,
                  color: _ForgotColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: _ForgotColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: _emailSent
                    ? _buildSuccessContent()
                    : _buildFormContent(),
              ),

              const SizedBox(height: 32),

              if (_emailSent)
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppTheme.buttonGradient,
                        borderRadius: BorderRadius.circular(27),
                        boxShadow: AppTheme.buttonShadow,
                      ),
                      child: const Text(
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
              color: _ForgotColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.lock_reset_outlined,
              color: _ForgotColors.primary,
              size: 40,
            ),
          ),

          const SizedBox(height: 24),

          // Label
          _buildLabel('CORREO ELECTRÓNICO'),
          const SizedBox(height: 8),

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

          const SizedBox(height: 28),

          // Botón
          GestureDetector(
            onTap: _isLoading ? null : _sendResetEmail,
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: _ForgotColors.vibrantBlue,
                borderRadius: BorderRadius.circular(27),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withAlpha(60),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
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
            gradient: _ForgotColors.vibrantBlue,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withAlpha(60),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: Colors.white,
            size: 48,
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          '¡Correo enviado!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _ForgotColors.onSurface,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'Revisa ${_emailController.text}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: _ForgotColors.onSurfaceVariant,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 20),

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
              : const Icon(Icons.refresh, size: 18),
          label: Text(
            _isLoading ? 'Enviando...' : 'Reenviar',
            style: const TextStyle(
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
      style: const TextStyle(
        color: _ForgotColors.onSurfaceVariant,
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
      style: const TextStyle(fontSize: 15, color: _ForgotColors.onSurface),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: _ForgotColors.outline.withAlpha(150), fontSize: 15),
        filled: true,
        fillColor: _ForgotColors.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
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
          borderSide: const BorderSide(color: _ForgotColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB41340), width: 1),
        ),
        prefixIcon: Icon(prefixIcon, color: _ForgotColors.outline, size: 20),
      ),
    );
  }
}
