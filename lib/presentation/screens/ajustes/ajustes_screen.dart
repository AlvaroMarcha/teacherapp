import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/notification_service.dart';
import '../../providers/notification_provider.dart';
import '../../providers/theme_provider.dart';

/// Hub de navegación hacia las sub-pantallas de ajustes.
class AjustesScreen extends ConsumerWidget {
  const AjustesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final appLocale = ref.watch(localeProvider);
    final notifEnabled = ref.watch(notifEnabledProvider);
    final notifMinutes = ref.watch(notifMinutesProvider);
    final l = ref.watch(appLocalizationsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.ajustesTitle)),
      body: ListView(
        children: [
          _Section(
            title: l.miCuenta,
            items: [
              _Item(
                icon: Icons.person_outline,
                label: l.miPerfil,
                subtitle: l.nombreDatosPersonales,
                onTap: () => context.push(AppRoutes.perfil),
              ),
            ],
          ),
          _Section(
            title: l.apariencia,
            items: const [],
            customContent: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.tema, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 12),
                  SegmentedButton<AppThemeMode>(
                    segments: [
                      ButtonSegment(
                        value: AppThemeMode.system,
                        icon: const Icon(Icons.brightness_auto_outlined),
                        label: Text(l.sistema),
                      ),
                      ButtonSegment(
                        value: AppThemeMode.light,
                        icon: const Icon(Icons.light_mode_outlined),
                        label: Text(l.claro),
                      ),
                      ButtonSegment(
                        value: AppThemeMode.dark,
                        icon: const Icon(Icons.dark_mode_outlined),
                        label: Text(l.oscuro),
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
            title: l.idioma,
            items: const [],
            customContent: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.idiomaApp, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 12),
                  SegmentedButton<AppLocale>(
                    segments: const [
                      ButtonSegment(
                        value: AppLocale.es,
                        label: Text('ES'),
                      ),
                      ButtonSegment(
                        value: AppLocale.en,
                        label: Text('EN'),
                      ),
                      ButtonSegment(
                        value: AppLocale.it,
                        label: Text('IT'),
                      ),
                    ],
                    selected: {appLocale},
                    onSelectionChanged: (selection) {
                      ref
                          .read(localeProvider.notifier)
                          .setLocale(selection.first);
                    },
                    showSelectedIcon: false,
                    style: const ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appLocale.label,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          _Section(
            title: l.notificaciones,
            items: const [],
            customContent: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.recordatorioClases,
                        style: AppTextStyles.bodyMedium),
                    value: notifEnabled,
                    onChanged: (val) async {
                      if (val) {
                        final granted = await NotificationService.instance
                            .requestPermission();
                        if (!granted) return;
                      }
                      ref.read(notifEnabledProvider.notifier).set(val);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(val
                                ? l.notificacionesActivadas
                                : l.notificacionesDesactivadas),
                          ),
                        );
                      }
                    },
                  ),
                  if (notifEnabled) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(l.minutosAntes, style: AppTextStyles.bodyMedium),
                        const Spacer(),
                        DropdownButton<int>(
                          value: notifMinutes,
                          underline: const SizedBox.shrink(),
                          items: const [5, 10, 15, 20, 30, 45, 60]
                              .map((m) => DropdownMenuItem(
                                    value: m,
                                    child: Text('$m min'),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(notifMinutesProvider.notifier).set(val);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          _Section(
            title: l.tarifasCondiciones,
            items: [
              _Item(
                icon: Icons.euro_outlined,
                label: l.tarifas,
                subtitle: l.tarifaGlobalPorFuente,
                onTap: () => context.push(AppRoutes.tarifas),
              ),
            ],
          ),
          _Section(
            title: l.datos,
            items: [
              _Item(
                icon: Icons.cloud_upload_outlined,
                label: l.sincronizacion,
                subtitle: l.proximamenteBackup,
                enabled: false,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l.versionInfo,
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
