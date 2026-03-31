import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/theme_provider.dart';

/// Pantalla de perfil del usuario (nombre, moneda preferida).
/// Los datos se persisten en shared_preferences (Sprint 2).
/// Por ahora usa variables de estado local.
class PerfilScreen extends ConsumerStatefulWidget {
  const PerfilScreen({super.key});

  @override
  ConsumerState<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends ConsumerState<PerfilScreen> {
  final _nombreCtrl = TextEditingController(text: 'Lau');
  bool _guardando = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = ref.watch(appLocalizationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.miPerfil),
        actions: [
          TextButton(
            onPressed: _guardando ? null : _guardar,
            child: Text(l.guardar),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(
              children: [
                const CircleAvatar(
                  radius: 48,
                  child: Icon(Icons.person, size: 40),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child:
                        const Icon(Icons.edit, size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(l.nombre, style: AppTextStyles.labelMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _nombreCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: l.tuNombre,
            ),
          ),
          const SizedBox(height: 24),
          Text(l.preferencias, style: AppTextStyles.titleSmall),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.moneda),
            trailing: const Text('EUR €'),
            subtitle: Text(l.masOpcionesProximamente),
          ),
          const SizedBox(height: 32),
          if (_guardando) const LinearProgressIndicator(),
        ],
      ),
    );
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    // TODO: persistir en SharedPreferences (Sprint 2)
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _guardando = false);
    if (mounted) {
      final l = ref.read(appLocalizationsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.perfilActualizado)),
      );
    }
  }
}
