import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../providers/theme_provider.dart';

/// Hub de navegación hacia las sub-pantallas de ajustes.
class AjustesScreen extends ConsumerWidget {
  const AjustesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        children: [
          _Section(
            title: 'Mi cuenta',
            items: [
              _Item(
                icon: Icons.person_outline,
                label: 'Mi perfil',
                subtitle: 'Nombre y datos personales',
                onTap: () => context.push(AppRoutes.perfil),
              ),
            ],
          ),
          _Section(
            title: 'Apariencia',
            items: const [],
            customContent: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tema', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 12),
                  SegmentedButton<AppThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: AppThemeMode.system,
                        icon: Icon(Icons.brightness_auto_outlined),
                        label: Text('Sistema'),
                      ),
                      ButtonSegment(
                        value: AppThemeMode.light,
                        icon: Icon(Icons.light_mode_outlined),
                        label: Text('Claro'),
                      ),
                      ButtonSegment(
                        value: AppThemeMode.dark,
                        icon: Icon(Icons.dark_mode_outlined),
                        label: Text('Oscuro'),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (selection) {
                      ref
                          .read(themeModeProvider.notifier)
                          .setMode(selection.first);
                    },
                    showSelectedIcon: false,
                    style: const ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _Section(
            title: 'Tarifas y condiciones',
            items: [
              _Item(
                icon: Icons.euro_outlined,
                label: 'Tarifas',
                subtitle: 'Tarifa global y por fuente',
                onTap: () => context.push(AppRoutes.tarifas),
              ),
            ],
          ),
          _Section(
            title: 'Datos',
            items: [
              _Item(
                icon: Icons.cloud_upload_outlined,
                label: 'Sincronización',
                subtitle: 'Próximamente — backup en la nube',
                enabled: false,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Teacher Finance v1.0.0\nOffline-first — tus datos siempre contigo',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<_Item> items;
  final Widget? customContent;
  const _Section(
      {required this.title, required this.items, this.customContent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(title.toUpperCase(),
              style: AppTextStyles.labelSmall.copyWith(
                letterSpacing: 1,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              )),
        ),
        if (customContent != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.hardEdge,
              child: customContent!,
            ),
          )
        else if (items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.hardEdge,
              child: Column(
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    items[i],
                    if (i < items.length - 1)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;
  const _Item({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: enabled ? null : Colors.grey),
      title: Text(label, style: TextStyle(color: enabled ? null : Colors.grey)),
      subtitle: Text(subtitle),
      trailing: enabled ? const Icon(Icons.chevron_right) : null,
      onTap: enabled ? onTap : null,
    );
  }
}
