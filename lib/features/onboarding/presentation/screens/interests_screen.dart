import 'package:flutter/material.dart';
import 'package:vyra/features/home/presentation/screens/home_screen.dart';
import 'package:vyra/services/onboarding_service.dart';

class InterestItem {
  final String name;
  final String emoji;

  const InterestItem({required this.name, required this.emoji});
}

final List<InterestItem> _interests = const [
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
          MaterialPageRoute(builder: (_) => const HomeScreen()),
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Título
              const Text(
                'Elige tus\nintereses',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              // Subtítulo
              Text(
                'Selecciona al menos 3 para personalizar tu experiencia.',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8E8E93),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 28),

              // Chips de intereses
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
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

              const SizedBox(height: 16),

              // Botón Continuar
              GestureDetector(
                onTap: _isSaving || !_canProceed ? null : _onContinue,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _canProceed
                        ? const Color(0xFF1A1A2E)
                        : const Color(0xFFE5E5EA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
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

              const SizedBox(height: 24),
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
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF9E6) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFD966)
                : const Color(0xFFE5E5EA),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              interest.emoji,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
            Text(
              interest.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF1A1A2E) : const Color(0xFF3C3C43),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
