import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pranaverse/core/localization/app_copy.dart';
import 'package:pranaverse/core/utils/responsive_helper.dart';
import 'package:pranaverse/core/widgets/glassmorphism/glass_container.dart';
import 'package:pranaverse/core/widgets/glassmorphism/glass_icon.dart';

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
      title: 'Zeno Breathing',
      subtitle: 'Release stress & tension',
      duration: '5 min',
      icon: Icons.psychology_outlined,
      color: const Color(0xFF4CAF50),
      gradient: const [Color(0xFF4CAF50), Color(0xFF2E7D32)],
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
      color: const Color(0xFF66BB6A),
      gradient: const [Color(0xFF66BB6A), Color(0xFF43A047)],
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
      color: const Color(0xFF81C784),
      gradient: const [Color(0xFF81C784), Color(0xFF4CAF50)],
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
      color: const Color(0xFFA5D6A7),
      gradient: const [Color(0xFFA5D6A7), Color(0xFF66BB6A)],
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
      color: const Color(0xFFC8E6C9),
      gradient: const [Color(0xFFC8E6C9), Color(0xFF81C784)],
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
      color: const Color(0xFF43A047),
      gradient: const [Color(0xFF43A047), Color(0xFF2E7D32)],
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
        name: 'All', icon: Icons.all_inclusive, color: Color(0xFF4CAF50)),
    CategoryData(name: 'Quick', icon: Icons.flash_on, color: Color(0xFF66BB6A)),
    CategoryData(
        name: 'Stress', icon: Icons.self_improvement, color: Color(0xFF81C784)),
    CategoryData(name: 'Focus', icon: Icons.psychology, color: Color(0xFFA5D6A7)),
    CategoryData(
        name: 'Sleep', icon: Icons.nightlight, color: Color(0xFF43A047)),
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
    print('BREATHING MENU: Navigating to route: $route');
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
      backgroundColor: const Color(0xFF0A1F15),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D2B1E), Color(0xFF0A1F15), Color(0xFF071810)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isLargeScreen ? (size.width - 1200) / 2 : 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 20)),

                // Breathing guide
                _buildBreathingGuide(context),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 24)),

                // Category filter
                SizedBox(
                  height: ResponsiveHelper.getResponsiveContainerHeight(context, mobileHeight: 56),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      return _buildCategoryItem(context, index);
                    },
                  ),
                ),

                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 24)),

                // Exercises grid - FIXED: Using Expanded to prevent overflow
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.only(bottom: ResponsiveHelper.getResponsivePadding(context, mobilePadding: 20)),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isSmallScreen ? 1 : (isLargeScreen ? 3 : 2),
                      crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 16),
                      mainAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 16),
                      childAspectRatio: _getChildAspectRatio(size),
                    ),
                    itemCount: _filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _filteredExercises[index];
                      return _buildExerciseCard(context, exercise, index);
                    },
                  ),
                ),
              ],
            ),
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

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 8)),
        Row(
          children: [
            // Back Button
            GlassIcon(
              icon: Icons.arrow_back_rounded,
              onTap: _goBackToMainMenu,
              size: ResponsiveHelper.getResponsiveIconSize(context, mobileSize: 24, tabletSize: 26, desktopSize: 28),
              iconColor: Colors.white,
              blur: 10,
              opacity: 0.1,
            ),
            SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppCopy.of(context, 'Breathing Exercises'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 28, tabletSize: 30, desktopSize: 32),
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 6)),
                  Text(
                    AppCopy.of(context, 'Master your breath to master your mind'),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 14, tabletSize: 15, desktopSize: 16),
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
        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 12)),
        Container(
          height: 4,
          width: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF4CAF50),
                const Color(0xFF81C784),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildBreathingGuide(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context, mobilePadding: 20)),
      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context, mobileRadius: 24)),
      blur: 15,
      opacity: 0.15,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF4CAF50).withOpacity(0.15),
          const Color(0xFF2E7D32).withOpacity(0.1),
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
                  AppCopy.of(context, 'Breathing Guide'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 20, tabletSize: 22, desktopSize: 24),
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 8)),
                Text(
                  AppCopy.of(context,
                      'Follow the animated circle. Inhale as it expands, exhale as it contracts.'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 14, tabletSize: 15, desktopSize: 16),
                    height: 1.5,
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 16)),
          AnimatedBuilder(
            animation: _breathAnimation,
            builder: (context, child) {
              return Container(
                width: ResponsiveHelper.getResponsiveContainerWidth(context, mobileWidth: 90),
                height: ResponsiveHelper.getResponsiveContainerHeight(context, mobileHeight: 90),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withOpacity(0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.2),
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
                            const Color(0xFF4CAF50).withOpacity(0.2),
                            const Color(0xFF2E7D32).withOpacity(0.1),
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
                            const Color(0xFF4CAF50).withOpacity(0.9),
                            const Color(0xFF2E7D32).withOpacity(0.6),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withOpacity(0.4),
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

  Widget _buildCategoryItem(BuildContext context, int index) {
    final category = _categories[index];
    final isSelected = index == _selectedCategory;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = index;
        });
      },
      child: GlassContainer(
        margin: EdgeInsets.only(
          right: index < _categories.length - 1 ? ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 12) : 0,
          left: index == 0 ? 0 : 0,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getResponsivePadding(context, mobilePadding: 20),
          vertical: ResponsiveHelper.getResponsivePadding(context, mobilePadding: 12),
        ),
        borderRadius: BorderRadius.circular(30),
        blur: isSelected ? 12 : 8,
        opacity: isSelected ? 0.2 : 0.1,
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  category.color.withOpacity(0.9),
                  category.color.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.02),
                ],
              ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: ResponsiveHelper.getResponsiveIconSize(context, mobileSize: 18, tabletSize: 19, desktopSize: 20),
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
            ),
            SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 8)),
            Text(
              AppCopy.of(context, category.name),
              style: TextStyle(
                color:
                    isSelected ? Colors.white : Colors.white.withOpacity(0.9),
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 14, tabletSize: 15, desktopSize: 16),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, ExerciseData exercise, int index) {
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
          child: GlassContainer(
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context, mobileRadius: 24)),
            blur: 15,
            opacity: 0.2,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: exercise.gradient,
            ),
            onTap: () => _navigateToExercise(exercise.route),
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
                  padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context, mobilePadding: 20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top row with icon and duration
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: ResponsiveHelper.getResponsiveContainerWidth(context, mobileWidth: 56),
                            height: ResponsiveHelper.getResponsiveContainerHeight(context, mobileHeight: 56),
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
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.getResponsivePadding(context, mobilePadding: 14),
                              vertical: ResponsiveHelper.getResponsivePadding(context, mobilePadding: 8),
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
                                SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 8)),
                                Text(
                                  AppCopy.of(context, exercise.duration),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 14, tabletSize: 15, desktopSize: 16),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Spacer
                      SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 16)),

                      // Title and subtitle
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppCopy.of(context, exercise.title),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 22, tabletSize: 24, desktopSize: 26),
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 8)),
                          Text(
                            AppCopy.of(context, exercise.subtitle),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 14, tabletSize: 15, desktopSize: 16),
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                      // Bottom row with difficulty and arrow
                      SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobileSpacing: 16)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.getResponsivePadding(context, mobilePadding: 14),
                              vertical: ResponsiveHelper.getResponsivePadding(context, mobilePadding: 10),
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
                              AppCopy.of(context, exercise.difficulty),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 13, tabletSize: 14, desktopSize: 15),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            width: ResponsiveHelper.getResponsiveContainerWidth(context, mobileWidth: 44),
                            height: ResponsiveHelper.getResponsiveContainerHeight(context, mobileHeight: 44),
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
