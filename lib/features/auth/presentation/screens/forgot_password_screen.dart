import 'package:flutter/material.dart';
import 'package:vyra/core/theme/app_theme.dart';
import 'package:vyra/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:vyra/features/auth/presentation/widgets/gradient_button.dart';
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
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Botón regresar
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withAlpha(51),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
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
                    color: Colors.white,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _emailSent 
                    ? 'Revisa tu correo para continuar'
                    : 'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withAlpha(204),
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Card blanca con formulario o mensaje de éxito
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryDark.withAlpha(51),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: _emailSent 
                    ? _buildSuccessContent()
                    : _buildFormContent(),
                ),
                
                const SizedBox(height: 32),
                
                // Volver al login
                if (_emailSent)
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Volver al inicio de sesión',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
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
              color: AppTheme.lightBlue,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.lock_reset_outlined,
              color: AppTheme.primaryBlue,
              size: 40,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Email
          CustomTextField(
            hintText: 'Correo electrónico',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _sendResetEmail(),
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: AppTheme.primaryBlue,
              size: 22,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa tu correo electrónico';
              }
              if (!value.contains('@')) {
                return 'Ingresa un correo válido';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 28),
          
          // Botón enviar
          GradientButton(
            text: 'Enviar enlace',
            onPressed: _sendResetEmail,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      children: [
        // Icono de éxito
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppTheme.buttonGradient,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withAlpha(77),
                blurRadius: 20,
                offset: const Offset(0, 8),
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
            color: AppTheme.textPrimary,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Text(
          'Hemos enviado un enlace de recuperación a:\n${_emailController.text}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Botón reenviar
        TextButton.icon(
          onPressed: _isLoading ? null : _sendResetEmail,
          icon: _isLoading 
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primaryBlue,
                ),
              )
            : const Icon(Icons.refresh, size: 18),
          label: Text(
            _isLoading ? 'Enviando...' : 'Reenviar correo',
            style: const TextStyle(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
