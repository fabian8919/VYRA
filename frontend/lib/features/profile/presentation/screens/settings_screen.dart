import 'package:flutter/material.dart';
import 'package:vyra/core/providers/theme_provider.dart';
import 'package:vyra/core/theme/app_theme.dart';
import 'package:vyra/services/auth_service.dart';
import 'package:vyra/services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settingsService = SettingsService();
  final _authService = AuthService();

  bool _notificationsEnabled = true;
  bool _privateProfile = false;
  bool _showActivity = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final notifications = await _settingsService.areNotificationsEnabled();
    final private = await _settingsService.isPrivateProfile();
    final activity = await _settingsService.showActivityStatus();

    if (mounted) {
      setState(() {
        _notificationsEnabled = notifications;
        _privateProfile = private;
        _showActivity = activity;
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cerrar sesión'),
        content: Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.signOut();
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Eliminar cuenta',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          'Esta acción no se puede deshacer. ¿Estás seguro de que deseas eliminar tu cuenta permanentemente?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Función no disponible en demo'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Acerca de Vyra'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.waves, color: Colors.white, size: 32),
            ),
            SizedBox(height: 16),
            Text(
              'Vyra',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Versión 1.0.0+1',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            SizedBox(height: 12),
            Text(
              'Descubre. Inspírate. Comparte.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textLight),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
        child: CustomScrollView(
          slivers: [
            // Header
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
                        'Configuración',
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
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección: Cuenta
                    _buildSectionTitle('CUENTA'),
                    SizedBox(height: 12),
                    _buildCard([
                      _buildToggleItem(
                        icon: Icons.lock_outline,
                        iconColor: Color(0xFF2563EB),
                        iconBgColor: Color(0xFFE7F3FF),
                        title: 'Perfil privado',
                        subtitle: 'Solo tus seguidores pueden ver tu contenido',
                        value: _privateProfile,
                        onChanged: (value) async {
                          setState(() => _privateProfile = value);
                          await _settingsService.setPrivateProfile(value);
                        },
                      ),
                      _buildDivider(),
                      _buildToggleItem(
                        icon: Icons.online_prediction,
                        iconColor: Color(0xFF10B981),
                        iconBgColor: Color(0xFFD1FAE5),
                        title: 'Mostrar estado de actividad',
                        subtitle: 'Permite que otros vean cuando estás en línea',
                        value: _showActivity,
                        onChanged: (value) async {
                          setState(() => _showActivity = value);
                          await _settingsService.setShowActivityStatus(value);
                        },
                      ),
                    ]),

                    SizedBox(height: 28),

                    // Sección: Preferencias
                    _buildSectionTitle('PREFERENCIAS'),
                    SizedBox(height: 12),
                    _buildCard([
                      _buildToggleItem(
                        icon: Icons.notifications_outlined,
                        iconColor: Color(0xFF2563EB),
                        iconBgColor: Color(0xFFE7F3FF),
                        title: 'Notificaciones push',
                        subtitle: 'Recibe alertas de likes, comentarios y seguidores',
                        value: _notificationsEnabled,
                        onChanged: (value) async {
                          setState(() => _notificationsEnabled = value);
                          await _settingsService.setNotificationsEnabled(value);
                        },
                      ),
                      _buildDivider(),
                      ListenableBuilder(
                        listenable: ThemeProvider.instance,
                        builder: (context, _) {
                          return _buildToggleItem(
                            icon: Icons.dark_mode_outlined,
                            iconColor: Color(0xFF565881),
                            iconBgColor: Color(0xFFE8E8FF),
                            title: 'Modo oscuro',
                            subtitle: 'Cambia la apariencia de la app',
                            value: ThemeProvider.instance.isDarkMode,
                            onChanged: (value) async {
                              await ThemeProvider.instance.setDarkMode(value);
                            },
                          );
                        },
                      ),
                    ]),

                    SizedBox(height: 28),

                    // Sección: Información
                    _buildSectionTitle('INFORMACIÓN'),
                    SizedBox(height: 12),
                    _buildCard([
                      _buildNavItem(
                        icon: Icons.info_outline,
                        iconColor: Color(0xFF2563EB),
                        iconBgColor: Color(0xFFE7F3FF),
                        title: 'Acerca de',
                        subtitle: 'Versión 1.0.0+1',
                        onTap: _showAboutDialog,
                      ),
                      _buildDivider(),
                      _buildNavItem(
                        icon: Icons.description_outlined,
                        iconColor: Color(0xFF565881),
                        iconBgColor: Color(0xFFE8E8FF),
                        title: 'Términos de servicio',
                        subtitle: 'Lee nuestros términos y condiciones',
                        onTap: () => _showComingSoon(),
                      ),
                      _buildDivider(),
                      _buildNavItem(
                        icon: Icons.privacy_tip_outlined,
                        iconColor: Color(0xFF565881),
                        iconBgColor: Color(0xFFE8E8FF),
                        title: 'Política de privacidad',
                        subtitle: 'Conoce cómo protegemos tus datos',
                        onTap: () => _showComingSoon(),
                      ),
                    ]),

                    SizedBox(height: 28),

                    // Sección: Sesión
                    _buildSectionTitle('SESIÓN'),
                    SizedBox(height: 12),
                    _buildCard([
                      _buildActionItem(
                        icon: Icons.logout,
                        iconColor: Colors.red,
                        iconBgColor: Color(0xFFFFE4E4),
                        title: 'Cerrar sesión',
                        textColor: Colors.red,
                        onTap: _logout,
                      ),
                      _buildDivider(),
                      _buildActionItem(
                        icon: Icons.delete_outline,
                        iconColor: Colors.red,
                        iconBgColor: Color(0xFFFFE4E4),
                        title: 'Eliminar cuenta',
                        textColor: Colors.red,
                        onTap: _deleteAccount,
                      ),
                    ]),

                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppTheme.textLight,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.outlineVariant.withAlpha(60),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: Color(0xFF2563EB),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 56,
      endIndent: 16,
      color: AppTheme.outlineVariant.withAlpha(50),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Próximamente...'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
