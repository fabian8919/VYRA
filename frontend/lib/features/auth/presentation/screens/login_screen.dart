import 'package:flutter/material.dart';
import 'package:vyra/core/theme/app_theme.dart';
import 'package:vyra/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:vyra/features/auth/presentation/screens/register_screen.dart';
import 'package:vyra/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
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
        backgroundColor: Color(0xFFB41340),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                SizedBox(height: 40),

                // Logo circular con imagen de onda azul
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF004EDB).withAlpha(30),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1E3A8A),
                            Color(0xFF3B82F6),
                          ],
                        ),
                      ),
                      child: CustomPaint(
                        size: Size(100, 100),
                        painter: WavePainter(),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // Nombre de la app - Vyra en azul cursiva
                Text(
                  'Vyra',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.primaryBlue,
                    letterSpacing: -1,
                  ),
                ),

                SizedBox(height: 8),

                // Tagline
                Text(
                  'Descubre. Inspírate. Comparte.',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),

                SizedBox(height: 40),

                // Card del formulario
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
                        // Email label
                        _buildLabel('CORREO ELECTRÓNICO'),
                        SizedBox(height: 10),
                        // Email input
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'tu@ejemplo.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.mail,
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

                        SizedBox(height: 24),

                        // Password row con label y link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildLabel('CONTRASEÑA'),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(
                                  color: AppTheme.primaryBlue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        // Password input
                        _buildTextField(
                          controller: _passwordController,
                          hintText: '••••••••',
                          obscureText: _obscurePassword,
                          prefixIcon: Icons.lock,
                          suffixIcon: _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          onSuffixTap: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa tu contraseña';
                            }
                            if (value.length < 6) {
                              return 'Mínimo 6 caracteres';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 28),

                        // Botón entrar
                        GestureDetector(
                          onTap: _isLoading ? null : _login,
                          child: Container(
                            width: double.infinity,
                            height: 54,
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
                            child: Center(
                              child: _isLoading
                                  ? SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'ENTRAR',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
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

                        SizedBox(height: 24),

                        // Separador
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: AppTheme.outlineVariant.withAlpha(100),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'O CONTINÚA CON',
                                style: TextStyle(
                                  color: AppTheme.onSurfaceVariant,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: AppTheme.outlineVariant.withAlpha(100),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        // Botones sociales
                        Row(
                          children: [
                            // Google
                            Expanded(
                              child: _buildSocialButton(
                                iconPath: 'google',
                                label: 'Google',
                                isGoogle: true,
                                onTap: () {},
                              ),
                            ),
                            SizedBox(width: 12),
                            // Facebook
                            Expanded(
                              child: _buildSocialButton(
                                iconPath: 'facebook',
                                label: 'Facebook',
                                isGoogle: false,
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 32),

                // Registro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes una cuenta? ',
                      style: TextStyle(
                        color: AppTheme.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Regístrate ahora',
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 40),

                // Footer
                Text(
                  '© 2024 VYRA APP INC.',
                  style: TextStyle(
                    color: AppTheme.outline,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),

                SizedBox(height: 12),

                // Links footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFooterLink('Privacidad'),
                    SizedBox(width: 24),
                    _buildFooterLink('Términos'),
                    SizedBox(width: 24),
                    _buildFooterLink('Soporte'),
                  ],
                ),

                SizedBox(height: 24),
              ],
            ),
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
      style: TextStyle(
        fontSize: 15,
        color: AppTheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppTheme.outline.withAlpha(150),
          fontSize: 15,
        ),
        filled: true,
        fillColor: AppTheme.surfaceContainerLowest,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        prefixIcon: Icon(
          prefixIcon,
          color: AppTheme.outline,
          size: 20,
        ),
        suffixIcon: suffixIcon != null
            ? GestureDetector(
                onTap: onSuffixTap,
                child: Icon(
                  suffixIcon,
                  color: AppTheme.outline.withAlpha(180),
                  size: 20,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildSocialButton({
    required String iconPath,
    required String label,
    required bool isGoogle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: isGoogle ? AppTheme.surfaceContainerLowest : Color(0xFF1877F2),
          borderRadius: BorderRadius.circular(24),
          border: isGoogle
              ? Border.all(color: AppTheme.outlineVariant.withAlpha(50))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isGoogle
                ? Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: CustomPaint(
                      size: Size(20, 20),
                      painter: GoogleLogoPainter(),
                    ),
                  )
                : Icon(
                    Icons.facebook,
                    color: Colors.white,
                    size: 20,
                  ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isGoogle ? AppTheme.onSurface : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        text,
        style: TextStyle(
          color: AppTheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// Pintor personalizado para el logo de onda
class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(180)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path();
    
    // Dibujar ondas suaves que simulan la imagen
    for (int i = 0; i < 4; i++) {
      final y = size.height * 0.35 + (i * 8);
      path.moveTo(size.width * 0.2, y);
      
      path.quadraticBezierTo(
        size.width * 0.4, y - 15,
        size.width * 0.5, y,
      );
      path.quadraticBezierTo(
        size.width * 0.6, y + 15,
        size.width * 0.8, y - 5,
      );
    }
    
    canvas.drawPath(path, paint);
    
    // Segunda capa de ondas más tenue
    final paint2 = Paint()
      ..color = Colors.white.withAlpha(100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    final path2 = Path();
    for (int i = 0; i < 3; i++) {
      final y = size.height * 0.45 + (i * 10);
      path2.moveTo(size.width * 0.25, y);
      
      path2.quadraticBezierTo(
        size.width * 0.45, y - 10,
        size.width * 0.55, y,
      );
      path2.quadraticBezierTo(
        size.width * 0.65, y + 10,
        size.width * 0.75, y - 3,
      );
    }
    
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Pintor para el logo de Google
class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;
    
    // Círculo rojo (arriba)
    final redPaint = Paint()..color = Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.8,
      2.0,
      false,
      redPaint..style = PaintingStyle.stroke..strokeWidth = 4,
    );
    
    // Círculo verde (abajo derecha)
    final greenPaint = Paint()..color = Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.8,
      2.0,
      false,
      greenPaint..style = PaintingStyle.stroke..strokeWidth = 4,
    );
    
    // Círculo azul (abajo izquierda)
    final bluePaint = Paint()..color = Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2.5,
      2.2,
      false,
      bluePaint..style = PaintingStyle.stroke..strokeWidth = 4,
    );
    
    // Amarillo (parte del medio)
    final yellowPaint = Paint()..color = Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -2.5,
      1.4,
      false,
      yellowPaint..style = PaintingStyle.stroke..strokeWidth = 4,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
