import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/backup_service.dart';
import '../../../core/services/cobro_auto_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/scheduled_backup_service.dart';
import '../../../core/utils/date_utils.dart';
import '../../providers/alumnos_provider.dart';
import '../../providers/backup_provider.dart';
import '../../providers/cobros_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/fuentes_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/sesiones_provider.dart';
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
            items: const [],
            customContent: _BackupSection(),
          ),
          _Section(
            title: 'Cobros automáticos',
            items: const [],
            customContent: _CobroAutoSection(),
          ),
          _Section(
            title: l.zonaPeligro,
            items: const [],
            customContent: _DangerZoneSection(),
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
  final VoidCallback onTap;
  const _Item({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

// ── Backup Section ───────────────────────────────────────────────────────────

class _BackupSection extends ConsumerStatefulWidget {
  const _BackupSection();

  @override
  ConsumerState<_BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends ConsumerState<_BackupSection> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      // Restaurar sesión de Google silenciosamente
      final drive = ref.read(driveBackupServiceProvider);
      final account = await drive.signInSilently();
      if (account != null && mounted) {
        ref.read(googleAccountProvider.notifier).state = account;
      }
      // Cargar preferencias de programación
      final enabled = await ScheduledBackupService.isEnabled();
      final time = await ScheduledBackupService.getScheduleTime();
      final type = await ScheduledBackupService.getScheduleType();
      if (mounted) {
        ref.read(backupScheduleEnabledProvider.notifier).state = enabled;
        ref.read(backupScheduleTimeProvider.notifier).state =
            TimeOfDay(hour: time.hour, minute: time.minute);
        ref.read(backupScheduleTypeProvider.notifier).state = type;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = ref.watch(appLocalizationsProvider);
    final googleAccount = ref.watch(googleAccountProvider);
    final lastBackup = ref.watch(lastDriveBackupProvider);
    final scheduleEnabled = ref.watch(backupScheduleEnabledProvider);
    final scheduleTime = ref.watch(backupScheduleTimeProvider);
    final scheduleType = ref.watch(backupScheduleTypeProvider);
    final lastAutoBackup = ref.watch(lastAutoBackupProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Copia local ──
          Text(l.copiaLocal, style: AppTextStyles.labelMedium),
          const SizedBox(height: 8),
          _ActionTile(
            icon: Icons.upload_file_outlined,
            label: l.exportarCopia,
            subtitle: l.exportarDesc,
            busy: _busy,
            onTap: _export,
          ),
          const Divider(height: 1),
          _ActionTile(
            icon: Icons.download_outlined,
            label: l.importarCopia,
            subtitle: l.importarDesc,
            busy: _busy,
            onTap: () => _confirmAndImport(context),
          ),

          const SizedBox(height: 20),

          // ── Google Drive ──
          Text(l.googleDrive, style: AppTextStyles.labelMedium),
          const SizedBox(height: 8),
          if (googleAccount == null) ...[
            _ActionTile(
              icon: Icons.cloud_outlined,
              label: l.conectarDrive,
              subtitle: '',
              busy: _busy,
              onTap: _signIn,
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.account_circle_outlined, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      googleAccount.email,
                      style: AppTextStyles.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            lastBackup.when(
              data: (date) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  date != null
                      ? '${l.ultimaCopia}: ${AppDateUtils.formatFullDate(date)}'
                      : l.sinCopiaPrevia,
                  style: AppTextStyles.caption,
                ),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  height: 14,
                  width: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
            _ActionTile(
              icon: Icons.cloud_upload_outlined,
              label: l.subirDrive,
              subtitle: '',
              busy: _busy,
              onTap: _uploadToDrive,
            ),
            const Divider(height: 1),
            _ActionTile(
              icon: Icons.cloud_download_outlined,
              label: l.restaurarDrive,
              subtitle: '',
              busy: _busy,
              onTap: () => _confirmAndRestoreFromDrive(context),
            ),
            const Divider(height: 1),
            _ActionTile(
              icon: Icons.logout_outlined,
              label: l.desconectarDrive,
              subtitle: '',
              busy: _busy,
              onTap: _signOut,
            ),
          ],

          const SizedBox(height: 20),

          // ── Copia automática ──
          Text(l.copiaAutomatica, style: AppTextStyles.labelMedium),
          const SizedBox(height: 4),
          Text(l.copiaAutomaticaDesc, style: AppTextStyles.caption),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.copiaAutomatica, style: AppTextStyles.bodyMedium),
            value: scheduleEnabled,
            onChanged: (val) => _toggleSchedule(val),
          ),
          if (scheduleEnabled) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: const Icon(Icons.access_time_outlined),
              title: Text(l.horaCopia),
              trailing: Text(
                scheduleTime.format(context),
                style: AppTextStyles.bodyMedium,
              ),
              onTap: () => _pickTime(context),
            ),
            const Divider(height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: const Icon(Icons.storage_outlined),
              title: Text(l.tipoCopia),
              trailing: SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'local',
                    label: Text(l.tipoLocal),
                  ),
                  const ButtonSegment(
                    value: 'drive',
                    label: Text('Drive'),
                  ),
                ],
                selected: {scheduleType},
                onSelectionChanged: (sel) => _changeScheduleType(sel.first),
                showSelectedIcon: false,
                style: const ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
            lastAutoBackup.when(
              data: (date) => date != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${l.ultimaCopiaAuto}: ${AppDateUtils.formatFullDate(date)}',
                        style: AppTextStyles.caption,
                      ),
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            if (scheduleType == 'local') ...[
              const Divider(height: 1),
              _ActionTile(
                icon: Icons.folder_open_outlined,
                label: l.ubicacionCopia,
                subtitle: '',
                busy: _busy,
                onTap: _showBackupPath,
              ),
              const Divider(height: 1),
              _ActionTile(
                icon: Icons.share_outlined,
                label: l.compartirCopia,
                subtitle: '',
                busy: _busy,
                onTap: _shareAutoBackup,
              ),
            ],
          ],
        ],
      ),
    );
  }

  // ── Acciones locales ──

  Future<void> _export() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(backupServiceProvider).exportBackup();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmAndImport(BuildContext ctx) async {
    final l = ref.read(appLocalizationsProvider);
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        title: Text(l.importarCopia),
        content: Text(l.confirmarImportar),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(l.confirmar),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      final backup = ref.read(backupServiceProvider);
      final db = ref.read(databaseProvider);
      final ok = await backup.importBackup(closeDb: () => db.close());
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.importExitoso)),
        );
      }
    } on BackupException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            e.message == 'invalid_file'
                ? l.archivoInvalido
                : 'Error: ${e.message}',
          )),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ── Acciones Google Drive ──

  Future<void> _signIn() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final drive = ref.read(driveBackupServiceProvider);
      final account = await drive.signIn();
      if (account != null) {
        ref.read(googleAccountProvider.notifier).state = account;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signOut() async {
    final drive = ref.read(driveBackupServiceProvider);
    await drive.signOut();
    ref.read(googleAccountProvider.notifier).state = null;
  }

  Future<void> _uploadToDrive() async {
    if (_busy) return;
    setState(() => _busy = true);
    final l = ref.read(appLocalizationsProvider);
    try {
      await ref.read(driveBackupServiceProvider).uploadBackup();
      ref.invalidate(lastDriveBackupProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.backupDriveExitoso)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmAndRestoreFromDrive(BuildContext ctx) async {
    final l = ref.read(appLocalizationsProvider);
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        title: Text(l.restaurarDrive),
        content: Text(l.confirmarRestaurarDrive),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(l.confirmar),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      final drive = ref.read(driveBackupServiceProvider);
      final db = ref.read(databaseProvider);
      final ok = await drive.downloadBackup(closeDb: () => db.close());
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.restaurarDriveExitoso)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ── Acciones programación ──

  Future<void> _toggleSchedule(bool enabled) async {
    final l = ref.read(appLocalizationsProvider);
    if (enabled) {
      // 1. Solicitar permiso de notificaciones (Android 13+)
      final granted = await NotificationService.instance.requestPermission();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Se necesitan notificaciones para avisar del backup')),
        );
      }

      final time = ref.read(backupScheduleTimeProvider);
      final type = ref.read(backupScheduleTypeProvider);
      await ScheduledBackupService.enable(
        hour: time.hour,
        minute: time.minute,
        type: type,
      );
      ref.read(backupScheduleEnabledProvider.notifier).state = true;

      // 2. Ejecutar backup de prueba inmediato
      try {
        final backupService = ref.read(backupServiceProvider);
        if (type == 'drive') {
          final driveService = ref.read(driveBackupServiceProvider);
          await driveService.uploadBackup();
        } else {
          await backupService.createAutoBackup();
        }
        ref.invalidate(lastAutoBackupProvider);
        // Mostrar notificación del sistema
        await NotificationService.instance.showInstant(
          id: 9999,
          title: l.primeraCopiaPrueba,
          body: type == 'drive' ? 'Google Drive' : 'Local',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.primeraCopiaPrueba)),
          );
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.copiaErrorBackup)),
          );
        }
      }
    } else {
      await ScheduledBackupService.disable();
      ref.read(backupScheduleEnabledProvider.notifier).state = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.copiaDesactivada)),
        );
      }
    }
  }

  Future<void> _pickTime(BuildContext ctx) async {
    final current = ref.read(backupScheduleTimeProvider);
    final picked = await showTimePicker(
      context: ctx,
      initialTime: current,
    );
    if (picked == null) return;
    ref.read(backupScheduleTimeProvider.notifier).state = picked;
    // Re-registrar con la nueva hora
    final type = ref.read(backupScheduleTypeProvider);
    await ScheduledBackupService.enable(
      hour: picked.hour,
      minute: picked.minute,
      type: type,
    );
  }

  Future<void> _changeScheduleType(String type) async {
    if (type == 'drive') {
      final account = ref.read(googleAccountProvider);
      if (account == null) {
        final l = ref.read(appLocalizationsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.driveNecesitaConexion)),
          );
        }
        return;
      }
    }
    ref.read(backupScheduleTypeProvider.notifier).state = type;
    final time = ref.read(backupScheduleTimeProvider);
    await ScheduledBackupService.enable(
      hour: time.hour,
      minute: time.minute,
      type: type,
    );
  }

  Future<void> _showBackupPath() async {
    final l = ref.read(appLocalizationsProvider);
    final path = await ref.read(backupServiceProvider).getAutoBackupPath();
    if (!mounted) return;
    if (path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.sinCopiaLocal)),
      );
      return;
    }
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.ubicacionCopia),
        content: SelectableText(path, style: AppTextStyles.bodySmall),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy, size: 18),
            label: Text(l.copiar),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: path));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l.rutaCopiada)),
              );
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cerrar),
          ),
        ],
      ),
    );
  }

  Future<void> _shareAutoBackup() async {
    final l = ref.read(appLocalizationsProvider);
    try {
      await ref.read(backupServiceProvider).shareAutoBackup();
    } on BackupException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.sinCopiaLocal)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool busy;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.busy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: busy
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon),
      title: Text(label),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      onTap: busy ? null : onTap,
    );
  }
}

// ── Cobro Auto Section ───────────────────────────────────────────────────────

class _CobroAutoSection extends ConsumerStatefulWidget {
  const _CobroAutoSection();

  @override
  ConsumerState<_CobroAutoSection> createState() => _CobroAutoSectionState();
}

class _CobroAutoSectionState extends ConsumerState<_CobroAutoSection> {
  int _diasFuturos = 30;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final dias = prefs.getInt(kCobroAutoDiasFuturos) ?? 30;
    if (mounted) {
      setState(() => _diasFuturos = dias);
    }
  }

  Future<void> _saveDiasFuturos(int dias) async {
    if (dias < 0 || dias > 365) return;

    setState(() => _isSaving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(kCobroAutoDiasFuturos, dias);

    // Regenerar cobros con la nueva configuración
    final db = ref.read(databaseProvider);
    await CobroAutoService.regenerarCobrosFuturos(db);
    ref.invalidate(cobrosProvider);

    setState(() {
      _diasFuturos = dias;
      _isSaving = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cobros actualizados'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _incrementar() => _saveDiasFuturos(_diasFuturos + 1);
  void _decrementar() => _saveDiasFuturos(_diasFuturos - 1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Genera automáticamente cobros pendientes para sesiones recurrentes.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Días futuros',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Genera cobros hasta $_diasFuturos días adelante',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: _isSaving || _diasFuturos <= 0
                              ? null
                              : _decrementar,
                          iconSize: 20,
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                        Container(
                          width: 60,
                          alignment: Alignment.center,
                          child: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _diasFuturos.toString(),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _isSaving || _diasFuturos >= 365
                              ? null
                              : _incrementar,
                          iconSize: 20,
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DangerZoneSection extends ConsumerStatefulWidget {
  const _DangerZoneSection();

  @override
  ConsumerState<_DangerZoneSection> createState() => _DangerZoneSectionState();
}

class _DangerZoneSectionState extends ConsumerState<_DangerZoneSection> {
  bool _busy = false;

  Future<void> _confirmAndResetData() async {
    final l = ref.read(appLocalizationsProvider);
    final confirmWord = l.eliminarMayusculas;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _ResetConfirmDialog(
        confirmWord: confirmWord,
        l: l,
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);

    try {
      // 1. Crear backup automático
      final backupService = BackupService();
      await backupService.createAutoBackup();
      final backupPath = await backupService.getAutoBackupPath();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${l.backupCreadoAntes}${backupPath != null ? '\n$backupPath' : ''}'),
          backgroundColor: Colors.green,
        ),
      );

      // 2. Eliminar todos los datos
      final database = ref.read(databaseProvider);
      await database.clearAllData();

      if (!mounted) return;

      // 3. Invalidar todos los providers
      ref.invalidate(alumnosProvider);
      ref.invalidate(sesionesRecurrentesProvider);
      ref.invalidate(fuentesProvider);
      ref.invalidate(dashboardProvider);
      ref.invalidate(cobrosProvider);
      ref.invalidate(cobrosPendientesProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.datosEliminados),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l.errorAlResetear}: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = ref.watch(appLocalizationsProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.error.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: theme.colorScheme.error,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.resetearDatos,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.resetearDatosDesc,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _busy ? null : _confirmAndResetData,
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_forever_outlined),
              label: Text(l.resetearDatos),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResetConfirmDialog extends StatefulWidget {
  final String confirmWord;
  final dynamic l;

  const _ResetConfirmDialog({
    required this.confirmWord,
    required this.l,
  });

  @override
  State<_ResetConfirmDialog> createState() => _ResetConfirmDialogState();
}

class _ResetConfirmDialogState extends State<_ResetConfirmDialog> {
  final _controller = TextEditingController();
  bool _isMatchingText = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Theme.of(context).colorScheme.error,
            size: 28,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(widget.l.confirmarReseteo),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.l.advertenciaReseteo,
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            widget.l.escribaEliminar,
            style: AppTextStyles.labelSmall,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: widget.confirmWord,
              border: const OutlineInputBorder(),
              errorText: _controller.text.isNotEmpty && !_isMatchingText
                  ? widget.l.textoCorrecto
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _isMatchingText = value == widget.confirmWord;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(widget.l.cancelar),
        ),
        FilledButton(
          onPressed:
              _isMatchingText ? () => Navigator.of(context).pop(true) : null,
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(widget.l.resetearDatos),
        ),
      ],
    );
  }
}
