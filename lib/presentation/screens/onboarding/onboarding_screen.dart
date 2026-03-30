import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Icon(Icons.school_rounded, color: Colors.white, size: 64),
              const SizedBox(height: 24),
              Text(
                AppStrings.appName,
                style: AppTextStyles.display.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.onboardingSubtitle,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                  onPressed: () => context.go(AppRoutes.dashboard),
                  child: const Text('Empezar'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
