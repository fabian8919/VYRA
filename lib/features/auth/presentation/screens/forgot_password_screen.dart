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
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Container(
              constraints: BoxConstraints(
                minHeight: size.height - 
                    MediaQuery.of(context).padding.top - 
                    MediaQuery.of(context).padding.bottom,
              ),
              padding: EdgeInsets.all(isSmallScreen ? 20 : 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: isSmallScreen ? 12 : 20),
                  
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: isSmallScreen ? 40 : 44,
                      height: isSmallScreen ? 40 : 44,
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
                  
                  SizedBox(height: isSmallScreen ? 24 : 40),
                  
                  Text(
                    'Recuperar\ncontraseña',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 30 : 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  Text(
                    _emailSent 
                      ? 'Revisa tu correo para continuar'
                      : 'Te enviaremos un enlace para restablecer tu contraseña',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.white.withAlpha(204),
                      height: 1.5,
                    ),
                  ),
                  
                  SizedBox(height: isSmallScreen ? 24 : 40),
                  
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
                      ? _buildSuccessContent(isSmallScreen)
                      : _buildFormContent(isSmallScreen),
                  ),
                  
                  SizedBox(height: isSmallScreen ? 24 : 32),
                  
                  if (_emailSent)
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Text(
                          'Volver al inicio',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: isSmallScreen ? 14 : 15,
                          ),
                        ),
                      ),
                    ),
                  
                  SizedBox(height: isSmallScreen ? 16 : 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(bool isSmallScreen) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            width: isSmallScreen ? 70 : 80,
            height: isSmallScreen ? 70 : 80,
            decoration: BoxDecoration(
              color: AppTheme.lightBlue,
              borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
            ),
            child: Icon(
              Icons.lock_reset_outlined,
              color: AppTheme.primaryBlue,
              size: isSmallScreen ? 35 : 40,
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 20 : 24),
          
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
                return 'Ingresa tu correo';
              }
              if (!value.contains('@')) {
                return 'Correo inválido';
              }
              return null;
            },
          ),
          
          SizedBox(height: isSmallScreen ? 24 : 28),
          
          GradientButton(
            text: 'Enviar enlace',
            onPressed: _sendResetEmail,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent(bool isSmallScreen) {
    return Column(
      children: [
        Container(
          width: isSmallScreen ? 90 : 100,
          height: isSmallScreen ? 90 : 100,
          decoration: BoxDecoration(
            gradient: AppTheme.buttonGradient,
            borderRadius: BorderRadius.circular(isSmallScreen ? 24 : 28),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withAlpha(77),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.mark_email_read_outlined,
            color: Colors.white,
            size: isSmallScreen ? 42 : 48,
          ),
        ),
        
        SizedBox(height: isSmallScreen ? 20 : 24),
        
        Text(
          '¡Correo enviado!',
          style: TextStyle(
            fontSize: isSmallScreen ? 22 : 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        
        SizedBox(height: isSmallScreen ? 10 : 12),
        
        Text(
          'Revisa ${_emailController.text}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 15,
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
        
        SizedBox(height: isSmallScreen ? 20 : 24),
        
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
}
