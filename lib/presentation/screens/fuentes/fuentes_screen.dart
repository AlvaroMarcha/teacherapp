import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import 'tabs/empleo_tab.dart';
import 'tabs/academia_tab.dart';
import 'tabs/particulares_tab.dart';

class FuentesScreen extends ConsumerWidget {
  const FuentesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.fuentesTitle),
          bottom: TabBar(
            labelStyle: AppTextStyles.labelLarge,
            unselectedLabelStyle: AppTextStyles.labelMedium,
            labelColor: AppColors.primary,
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurfaceVariant,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: AppStrings.tabAround),
              Tab(text: AppStrings.tabAngels),
              Tab(text: AppStrings.tabParticulares),
            ],
          ),
        ),
        body: const TabBarView(
          children: [EmpleoTab(), AcademiaTab(), ParticularesTab()],
        ),
      ),
    );
  }
}
