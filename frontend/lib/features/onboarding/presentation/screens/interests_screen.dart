import 'package:flutter/material.dart';
import 'package:vyra/core/theme/app_theme.dart';
import 'package:vyra/features/home/presentation/screens/home_screen.dart';
import 'package:vyra/services/onboarding_service.dart';

class InterestItem {
  final String name;
  final String emoji;

  InterestItem({required this.name, required this.emoji});
}

final List<InterestItem> _interests = [
  InterestItem(name: 'Música', emoji: '🎵'),
  InterestItem(name: 'Deportes', emoji: '⚽'),
  InterestItem(name: 'Tecnología', emoji: '💻'),
  InterestItem(name: 'Viajes', emoji: '✈️'),
  InterestItem(name: 'Comida', emoji: '🍔'),
  InterestItem(name: 'Arte', emoji: '🎨'),
  InterestItem(name: 'Moda', emoji: '👗'),
  InterestItem(name: 'Cine', emoji: '🎬'),
  InterestItem(name: 'Fotografía', emoji: '📷'),
  InterestItem(name: 'Gaming', emoji: '🎮'),
  InterestItem(name: 'Libros', emoji: '📚'),
  InterestItem(name: 'Fitness', emoji: '💪'),
  InterestItem(name: 'Naturaleza', emoji: '🌿'),
  InterestItem(name: 'Negocios', emoji: '📈'),
  InterestItem(name: 'Ciencia', emoji: '🔬'),
  InterestItem(name: 'Humor', emoji: '😂'),
  InterestItem(name: 'Belleza', emoji: '💄'),
  InterestItem(name: 'Mascotas', emoji: '🐶'),
];

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final Set<String> _selectedInterests = {};
  bool _isSaving = false;

  bool get _canProceed => _selectedInterests.length >= 3;

  void _toggleInterest(String name) {
    setState(() {
      if (_selectedInterests.contains(name)) {
        _selectedInterests.remove(name);
      } else {
        _selectedInterests.add(name);
      }
    });
  }

  Future<void> _onContinue() async {
    if (!_canProceed) return;

    setState(() => _isSaving = true);

    try {
      await OnboardingService().markInterestsCompleted();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => HomeScreen()),
          (route) => false,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),

              // Título
              Text(
                'Elige tus\nintereses',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),

              SizedBox(height: 8),

              // Subtítulo
              Text(
                'Selecciona al menos 3 para personalizar tu experiencia.',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),

              SizedBox(height: 28),

              // Chips de intereses
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 12,
                    children: _interests.map((interest) {
                      final isSelected = _selectedInterests.contains(interest.name);
                      return _InterestChip(
                        interest: interest,
                        isSelected: isSelected,
                        onTap: () => _toggleInterest(interest.name),
                      );
                    }).toList(),
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Botón Continuar
              GestureDetector(
                onTap: _isSaving || !_canProceed ? null : _onContinue,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _canProceed
                        ? AppTheme.textPrimary
                        : AppTheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: _isSaving
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Continuar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
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
    );
  }
}

class _InterestChip extends StatelessWidget {
  final InterestItem interest;
  final bool isSelected;
  final VoidCallback onTap;

  const _InterestChip({
    required this.interest,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.surfaceContainer : AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue
                : AppTheme.outlineVariant,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 12,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              interest.emoji,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(width: 8),
            Text(
              interest.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
