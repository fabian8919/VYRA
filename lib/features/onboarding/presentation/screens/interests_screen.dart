import 'package:flutter/material.dart';
import 'package:vyra/features/home/presentation/screens/home_screen.dart';
import 'package:vyra/services/onboarding_service.dart';

class InterestCategory {
  final String name;
  final IconData icon;

  const InterestCategory({required this.name, required this.icon});
}

final List<InterestCategory> _categories = const [
  InterestCategory(name: 'Música', icon: Icons.music_note),
  InterestCategory(name: 'Deportes', icon: Icons.sports_soccer),
  InterestCategory(name: 'Tecnología', icon: Icons.computer),
  InterestCategory(name: 'Viajes', icon: Icons.flight),
  InterestCategory(name: 'Comida', icon: Icons.restaurant),
  InterestCategory(name: 'Arte', icon: Icons.palette),
  InterestCategory(name: 'Moda', icon: Icons.checkroom),
  InterestCategory(name: 'Cine', icon: Icons.movie),
  InterestCategory(name: 'Fotografía', icon: Icons.camera_alt),
  InterestCategory(name: 'Gaming', icon: Icons.sports_esports),
  InterestCategory(name: 'Libros', icon: Icons.menu_book),
  InterestCategory(name: 'Fitness', icon: Icons.fitness_center),
  InterestCategory(name: 'Naturaleza', icon: Icons.forest),
  InterestCategory(name: 'Negocios', icon: Icons.trending_up),
  InterestCategory(name: 'Ciencia', icon: Icons.science),
];

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final Set<String> _selectedCategories = {};
  bool _isSaving = false;

  bool get _canProceed => _selectedCategories.length >= 3;

  void _toggleCategory(String name) {
    setState(() {
      if (_selectedCategories.contains(name)) {
        _selectedCategories.remove(name);
      } else {
        _selectedCategories.add(name);
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
      backgroundColor: const Color(0xFFF0F0FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // Título
              const Text(
                '¿Qué te interesa?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF292B51),
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),

              // Subtítulo
              Text(
                'Selecciona al menos 3 categorías para personalizar tu experiencia.',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF565881),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 8),

              // Contador
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _canProceed
                      ? const Color(0xFF2563EB).withAlpha(20)
                      : const Color(0xFF565881).withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_selectedCategories.length} de 3 seleccionados',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _canProceed
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF565881),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Grid de categorías
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.35,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategories.contains(category.name);

                    return _CategoryCard(
                      category: category,
                      isSelected: isSelected,
                      onTap: () => _toggleCategory(category.name),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Botón continuar
              GestureDetector(
                onTap: _isSaving ? null : _onContinue,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: _canProceed
                        ? const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF1D4ED8),
                              Color(0xFF3B82F6),
                            ],
                          )
                        : null,
                    color: _canProceed ? null : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: _canProceed
                        ? [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withAlpha(60),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: _isSaving
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'CONTINUAR',
                                style: TextStyle(
                                  color: _canProceed
                                      ? Colors.white
                                      : Colors.grey.shade500,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                color: _canProceed
                                    ? Colors.white
                                    : Colors.grey.shade500,
                                size: 20,
                              ),
                            ],
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

class _CategoryCard extends StatelessWidget {
  final InterestCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
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
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF3B82F6),
                    Color(0xFF2563EB),
                    Color(0xFF1D4ED8),
                  ],
                  stops: [0.0, 0.5, 1.0],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFF8FAFF),
                  ],
                ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withAlpha(77),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withAlpha(15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
          border: isSelected
              ? null
              : Border.all(
                  color: const Color(0xFFC4C4E0).withAlpha(80),
                  width: 1,
                ),
        ),
        child: Stack(
          children: [
            // Contenido centrado
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category.icon,
                    size: 32,
                    color: isSelected ? Colors.white : const Color(0xFF2563EB),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF292B51),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

            // Checkmark cuando está seleccionado
            if (isSelected)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 14,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
