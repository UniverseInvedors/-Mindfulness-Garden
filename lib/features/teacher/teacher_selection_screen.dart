import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pranaverse/core/widgets/character/teacher_personality.dart';
import 'package:pranaverse/core/widgets/glassmorphism/glass_card.dart';
import 'package:pranaverse/core/widgets/glassmorphism/glass_container.dart';
import 'package:pranaverse/core/utils/responsive_helper.dart';
import 'package:pranaverse/l10n/app_localizations.dart';

class TeacherSelectionScreen extends ConsumerWidget {
  const TeacherSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final teacher = ref.watch(teacherPreferenceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1F),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0D0D1F),
              const Color(0xFF1a1a2e),
              const Color(0xFF16213e),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, l10n),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(
                    ResponsiveHelper.getResponsivePadding(context, mobilePadding: 20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIntroText(context, l10n),
                      const SizedBox(height: 32),
                      _buildTeacherCards(context, ref, teacher),
                      const SizedBox(height: 32),
                      _buildSelectedTeacherInfo(context, teacher),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getResponsivePadding(context, mobilePadding: 20),
        vertical: ResponsiveHelper.getResponsivePadding(context, mobilePadding: 16),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Choose Your Guide',
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 24, tabletSize: 28, desktopSize: 32),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroText(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Your Meditation Teacher',
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 20, tabletSize: 22, desktopSize: 24),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Each teacher offers unique guidance for your mindfulness journey. Choose the one that resonates with you.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 14, tabletSize: 15, desktopSize: 16),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTeacherCards(BuildContext context, WidgetRef ref, TeacherPersonality teacher) {
    return Column(
      children: TeacherPersonality.values.map((personality) {
        final appearance = TeacherAppearance.personalities[personality]!;
        final isSelected = personality == teacher;

        return GestureDetector(
          onTap: () async {
            await ref.read(teacherPreferenceProvider.notifier).setTeacher(personality);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(bottom: 20),
            padding: EdgeInsets.all(
              ResponsiveHelper.getResponsivePadding(context, mobilePadding: 20),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [
                        appearance.auraPrimary.withOpacity(0.3),
                        appearance.auraSecondary.withOpacity(0.2),
                      ]
                    : [
                        Colors.white.withOpacity(0.05),
                        Colors.white.withOpacity(0.02),
                      ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? appearance.auraPrimary : Colors.white.withOpacity(0.1),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: appearance.auraPrimary.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                // Teacher Avatar
                Container(
                  width: ResponsiveHelper.getResponsiveContainerWidth(context, mobileWidth: 80, tabletWidth: 90, desktopWidth: 100),
                  height: ResponsiveHelper.getResponsiveContainerHeight(context, mobileHeight: 80, tabletHeight: 90, desktopHeight: 100),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        appearance.auraPrimary,
                        appearance.auraSecondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: appearance.auraPrimary.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _getTeacherIcon(personality),
                      color: Colors.white,
                      size: ResponsiveHelper.getResponsiveIconSize(context, mobileSize: 36, tabletSize: 40, desktopSize: 44),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Teacher Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            appearance.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 18, tabletSize: 20, desktopSize: 22),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: appearance.auraPrimary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'SELECTED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 10, tabletSize: 11, desktopSize: 12),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getTeacherDescription(personality),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 13, tabletSize: 14, desktopSize: 15),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildTraitChip('Wisdom', appearance.auraPrimary),
                          const SizedBox(width: 8),
                          _buildTraitChip('Calm', appearance.auraSecondary),
                        ],
                      ),
                    ],
                  ),
                ),
                // Selection Indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? appearance.auraPrimary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? appearance.auraPrimary : Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: Colors.white,
                          size: ResponsiveHelper.getResponsiveIconSize(context, mobileSize: 14, tabletSize: 16, desktopSize: 18),
                        )
                      : null,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTraitChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSelectedTeacherInfo(BuildContext context, TeacherPersonality teacher) {
    final appearance = TeacherAppearance.personalities[teacher]!;

    return GlassCard(
      padding: EdgeInsets.all(
        ResponsiveHelper.getResponsivePadding(context, mobilePadding: 20),
      ),
      borderRadius: BorderRadius.circular(20),
      blur: 20,
      opacity: 0.1,
      gradient: LinearGradient(
        colors: [
          appearance.auraPrimary.withOpacity(0.2),
          appearance.auraSecondary.withOpacity(0.1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customize ${appearance.name}',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 16, tabletSize: 18, desktopSize: 20),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _buildCustomizationOption(
            context,
            'Voice Tone',
            'Adjust the teacher\'s voice characteristics',
            Icons.graphic_eq,
            appearance.auraPrimary,
          ),
          const SizedBox(height: 12),
          _buildCustomizationOption(
            context,
            'Guidance Style',
            'Choose how detailed the guidance should be',
            Icons.psychology,
            appearance.auraSecondary,
          ),
          const SizedBox(height: 12),
          _buildCustomizationOption(
            context,
            'Appearance',
            'Customize visual elements',
            Icons.palette,
            appearance.auraPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizationOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return GlassContainer(
      padding: EdgeInsets.all(
        ResponsiveHelper.getResponsivePadding(context, mobilePadding: 16),
      ),
      borderRadius: BorderRadius.circular(16),
      blur: 10,
      opacity: 0.1,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: ResponsiveHelper.getResponsiveIconSize(context, mobileSize: 20, tabletSize: 22, desktopSize: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 14, tabletSize: 15, desktopSize: 16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobileSize: 12, tabletSize: 13, desktopSize: 14),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.white.withOpacity(0.4),
            size: ResponsiveHelper.getResponsiveIconSize(context, mobileSize: 20, tabletSize: 22, desktopSize: 24),
          ),
        ],
      ),
    );
  }

  IconData _getTeacherIcon(TeacherPersonality personality) {
    switch (personality) {
      case TeacherPersonality.buddha:
        return Icons.self_improvement;
      case TeacherPersonality.zeno:
        return Icons.person;
      case TeacherPersonality.monk:
        return Icons.accessibility;
    }
  }

  String _getTeacherDescription(TeacherPersonality personality) {
    switch (personality) {
      case TeacherPersonality.buddha:
        return 'Ancient wisdom and peaceful guidance for deep meditation and inner peace.';
      case TeacherPersonality.zeno:
        return 'Modern coaching approach with motivational energy and practical mindfulness techniques.';
      case TeacherPersonality.monk:
        return 'Traditional discipline and structured practice for building lasting meditation habits.';
    }
  }
}
