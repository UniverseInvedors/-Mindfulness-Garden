import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BreathingMenuScreen extends StatefulWidget {
  const BreathingMenuScreen({super.key});

  @override
  State<BreathingMenuScreen> createState() => _BreathingMenuScreenState();
}

class _BreathingMenuScreenState extends State<BreathingMenuScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<ExerciseData> _exercises = [
    ExerciseData(
      title: 'Yoga with Zeno',
      subtitle: '2.5D immersive yoga session',
      duration: '15 min',
      icon: Icons.self_improvement,
      color: const Color(0xFF9d4edd),
      gradient: const [Color(0xFF9d4edd), Color(0xFF3a0ca3)],
      route: '/yoga',
      difficulty: 'All Levels',
      description: 'Guided yoga poses in a beautiful 2.5D world',
      benefits: ['Flexibility', 'Strength', 'Mindfulness'],
      tags: ['Yoga', 'Immersive', 'All Levels'],
    ),
    ExerciseData(
      title: 'Zeno Breathing',
      subtitle: 'Release stress & tension',
      duration: '5 min',
      icon: Icons.psychology_outlined,
      color: const Color(0xFF00b4d8),
      gradient: const [Color(0xFF00b4d8), Color(0xFF0077b6)],
      route: '/breathing/zeno',
      difficulty: 'Easy',
      description: 'Gentle guided breathing for stress relief',
      benefits: ['Calms mind', 'Reduces anxiety', 'Improves focus'],
      tags: ['Stress Relief', 'Quick', 'Beginner'],
    ),
    ExerciseData(
      title: '4-7-8 Breathing',
      subtitle: 'For anxiety & sleep',
      duration: '4 min',
      icon: Icons.nightlight_round_outlined,
      color: const Color(0xFF9d4edd),
      gradient: const [Color(0xFF9d4edd), Color(0xFF560bad)],
      route: '/breathing/478',
      difficulty: 'Medium',
      description: 'Deep breathing pattern for relaxation',
      benefits: ['Promotes sleep', 'Reduces stress', 'Balances nervous system'],
      tags: ['Sleep', 'Anxiety', 'Intermediate'],
    ),
    ExerciseData(
      title: 'Box Breathing',
      subtitle: 'Improve focus & calm',
      duration: '5 min',
      icon: Icons.crop_square_outlined,
      color: const Color(0xFF38b000),
      gradient: const [Color(0xFF38b000), Color(0xFF2d6a4f)],
      route: '/breathing/box',
      difficulty: 'Easy',
      description: 'Military technique for focus and control',
      benefits: ['Enhances focus', 'Reduces stress', 'Improves performance'],
      tags: ['Focus', 'Military', 'Quick'],
    ),
    ExerciseData(
      title: 'Breath Awareness',
      subtitle: 'Mindfulness meditation',
      duration: '10 min',
      icon: Icons.self_improvement_outlined,
      color: const Color(0xFFffb700),
      gradient: const [Color(0xFFffb700), Color(0xFFf48c06)],
      route: '/breathing/awareness',
      difficulty: 'Beginner',
      description: 'Mindful observation of natural breath',
      benefits: [
        'Increases awareness',
        'Reduces anxiety',
        'Improves mindfulness'
      ],
      tags: ['Mindfulness', 'Meditation', 'Beginner'],
    ),
    ExerciseData(
      title: 'Alternate Nostril',
      subtitle: 'Balance & energy flow',
      duration: '7 min',
      icon: Icons.air_outlined,
      color: const Color(0xFFf72585),
      gradient: const [Color(0xFFf72585), Color(0xFFb5179e)],
      route: '/breathing/alternate',
      difficulty: 'Medium',
      description: 'Traditional technique for balancing energy',
      benefits: ['Balances hemispheres', 'Reduces stress', 'Increases focus'],
      tags: ['Balance', 'Energy', 'Traditional'],
    ),
    ExerciseData(
      title: 'Deep Diaphragmatic',
      subtitle: 'Full relaxation',
      duration: '8 min',
      icon: Icons.waves_outlined,
      color: const Color(0xFF4361ee),
      gradient: const [Color(0xFF4361ee), Color(0xFF3a0ca3)],
      route: '/breathing/diaphragmatic',
      difficulty: 'Easy',
      description: 'Deep belly breathing for complete relaxation',
      benefits: [
        'Reduces tension',
        'Improves oxygen flow',
        'Calms nervous system'
      ],
      tags: ['Relaxation', 'Deep Breathing', 'Beginner'],
    ),
  ];

  int _selectedCategory = 0;
  final List<CategoryData> _categories = [
    CategoryData(
        name: 'All', icon: Icons.all_inclusive, color: Color(0xFF667eea)),
    CategoryData(name: 'Quick', icon: Icons.flash_on, color: Color(0xFF00b4d8)),
    CategoryData(
        name: 'Stress', icon: Icons.self_improvement, color: Color(0xFFf72585)),
    CategoryData(
        name: 'Focus', icon: Icons.psychology, color: Color(0xFF38b000)),
    CategoryData(
        name: 'Sleep', icon: Icons.nightlight, color: Color(0xFF9d4edd)),
  ];

  @override
  void initState() {
    super.initState();

    // Breathing animation for background
    _breathController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);

    _breathAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOutSine),
    );

    // Pulse animation for cards
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _navigateToExercise(String route) {
    context.push(route);
  }

  void _goBackToMainMenu() {
    context.go('/main');
  }

  List<ExerciseData> get _filteredExercises {
    if (_selectedCategory == 0) return _exercises;

    final category = _categories[_selectedCategory].name.toLowerCase();
    return _exercises.where((exercise) {
      if (category == 'quick') {
        return exercise.duration.contains('5') ||
            exercise.duration.contains('4');
      }
      if (category == 'stress') {
        return exercise.tags.contains('Stress Relief') ||
            exercise.subtitle.contains('stress');
      }
      if (category == 'focus') {
        return exercise.tags.contains('Focus') ||
            exercise.subtitle.contains('focus');
      }
      if (category == 'sleep') {
        return exercise.tags.contains('Sleep') ||
            exercise.subtitle.contains('sleep');
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isLargeScreen = size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isLargeScreen ? (size.width - 1200) / 2 : 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context, size),
              const SizedBox(height: 20),

              // Breathing guide
              _buildBreathingGuide(size),
              const SizedBox(height: 24),

              // Category filter
              SizedBox(
                height: 56,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    return _buildCategoryItem(index, size);
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Exercises grid - FIXED: Using Expanded to prevent overflow
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isSmallScreen ? 1 : (isLargeScreen ? 3 : 2),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: _getChildAspectRatio(size),
                  ),
                  itemCount: _filteredExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _filteredExercises[index];
                    return _buildExerciseCard(exercise, index, size);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getChildAspectRatio(Size size) {
    if (size.width < 380) return 1.4;
    if (size.width < 500) return 1.5;
    if (size.width < 600) return 1.3;
    if (size.width < 800) return 1.4;
    if (size.width < 1000) return 1.2;
    return 1.1;
  }

  Widget _buildHeader(BuildContext context, Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            // Back Button
            GestureDetector(
              onTap: _goBackToMainMenu,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: 24,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Breathing Exercises',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Master your breath to master your mind',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 4,
          width: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF00b4d8),
                const Color(0xFF9d4edd),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildBreathingGuide(Size size) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00b4d8).withOpacity(0.15),
            const Color(0xFF0077b6).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF00b4d8).withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00b4d8).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Breathing Guide',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Follow the animated circle. Inhale as it expands, exhale as it contracts.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                    height: 1.5,
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          AnimatedBuilder(
            animation: _breathAnimation,
            builder: (context, child) {
              return Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF00b4d8).withOpacity(0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00b4d8).withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulse ring
                    Container(
                      width: 90 * _breathAnimation.value,
                      height: 90 * _breathAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF00b4d8).withOpacity(0.2),
                            const Color(0xFF0077b6).withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                    // Main breathing circle
                    Container(
                      width: 55 * (0.9 + (_breathAnimation.value - 1) * 0.3),
                      height: 55 * (0.9 + (_breathAnimation.value - 1) * 0.3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF00b4d8).withOpacity(0.9),
                            const Color(0xFF0077b6).withOpacity(0.6),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00b4d8).withOpacity(0.4),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.air,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(int index, Size size) {
    final category = _categories[index];
    final isSelected = index == _selectedCategory;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = index;
        });
      },
      child: Container(
        margin: EdgeInsets.only(
          right: index < _categories.length - 1 ? 12 : 0,
          left: index == 0 ? 0 : 0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    category.color.withOpacity(0.9),
                    category.color.withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? category.color.withOpacity(0.6)
                : Colors.white.withOpacity(0.2),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: category.color.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
            ),
            const SizedBox(width: 8),
            Text(
              category.name,
              style: TextStyle(
                color:
                    isSelected ? Colors.white : Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(ExerciseData exercise, int index, Size size) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value + (index % 2 == 0 ? 0.01 : 0.0),
          child: child,
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _navigateToExercise(exercise.route),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: exercise.gradient,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: exercise.color.withOpacity(0.4),
                  blurRadius: 25,
                  spreadRadius: 2,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Decorative elements
                Positioned(
                  top: -30,
                  right: -30,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -40,
                  left: -40,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.03),
                    ),
                  ),
                ),

                // Content - FIXED: Simple layout to prevent overflow
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top row with icon and duration
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              exercise.icon,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.timer_outlined,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  exercise.duration,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Spacer
                      const SizedBox(height: 16),

                      // Title and subtitle
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            exercise.subtitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                      // Bottom row with difficulty and arrow
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              exercise.difficulty,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ExerciseData {
  final String title;
  final String subtitle;
  final String duration;
  final IconData icon;
  final Color color;
  final List<Color> gradient;
  final String route;
  final String difficulty;
  final String description;
  final List<String> benefits;
  final List<String> tags;

  ExerciseData({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.icon,
    required this.color,
    required this.gradient,
    required this.route,
    required this.difficulty,
    required this.description,
    required this.benefits,
    required this.tags,
  });
}

class CategoryData {
  final String name;
  final IconData icon;
  final Color color;

  CategoryData({
    required this.name,
    required this.icon,
    required this.color,
  });
}
