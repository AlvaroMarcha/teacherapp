import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/auth_service.dart';
import '../../providers/theme_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _loading = false;
  bool _isFirstSetup = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkSetup();
  }

  Future<void> _checkSetup() async {
    final setup = await _authService.isSetup();
    if (mounted) setState(() => _isFirstSetup = !setup);
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_isFirstSetup) {
        await _authService.saveCredentials(
          _userCtrl.text.trim(),
          _passCtrl.text,
        );
        authNotifier.value = true;
      } else {
        final ok = await _authService.validateCredentials(
          _userCtrl.text.trim(),
          _passCtrl.text,
        );
        if (ok) {
          authNotifier.value = true;
        } else {
          setState(() => _error =
              ref.read(appLocalizationsProvider).credencialesIncorrectas);
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showRecovery() async {
    final l = ref.read(appLocalizationsProvider);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.accederCredenciales),
        content: Text(l.mostrarCredenciales),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.ver),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final creds = await _authService.getCredentials();
    if (!mounted) return;

    if (creds.username == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.noHayCredenciales)),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (_) => _CredentialsDialog(
        username: creds.username!,
        password: creds.password ?? '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = ref.watch(appLocalizationsProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Logo / icono ─────────────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/images/logo-laura.png',
                      width: 120,
                      height: 120,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l.appName,
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isFirstSetup
                        ? l.loginSubtitleCreate
                        : l.loginSubtitleAccess,
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 32),

                  // ── Usuario ──────────────────────────────────
                  TextFormField(
                    controller: _userCtrl,
                    decoration: InputDecoration(
                      labelText: l.usuario,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? l.requerido : null,
                  ),
                  const SizedBox(height: 16),

                  // ── Contraseña ───────────────────────────────
                  TextFormField(
                    controller: _passCtrl,
                    decoration: InputDecoration(
                      labelText: l.contrasena,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    validator: (v) {
                      if (v == null || v.isEmpty) return l.requerido;
                      if (_isFirstSetup && v.length < 4) {
                        return l.minCaracteres;
                      }
                      return null;
                    },
                  ),

                  // ── Error ────────────────────────────────────
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: cs.error,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // ── Botón principal ──────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_isFirstSetup ? l.crearAcceso : l.entrar),
                    ),
                  ),

                  // ── Recuperar contraseña ─────────────────────
                  if (!_isFirstSetup) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _showRecovery,
                      child: Text(l.olvidasteContrasena),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Dialog de credenciales guardadas ────────────────────────────────────────

class _CredentialsDialog extends ConsumerStatefulWidget {
  const _CredentialsDialog({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;

  @override
  ConsumerState<_CredentialsDialog> createState() => _CredentialsDialogState();
}

class _CredentialsDialogState extends ConsumerState<_CredentialsDialog> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final l = ref.watch(appLocalizationsProvider);
    return AlertDialog(
      title: Text(l.tusCredenciales),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CredentialRow(label: l.usuario, value: widget.username, mask: false),
          const SizedBox(height: 12),
          _CredentialRow(
            label: l.contrasena,
            value: widget.password,
            mask: !_showPassword,
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            icon: Icon(
              _showPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18,
            ),
            label:
                Text(_showPassword ? l.ocultarContrasena : l.mostrarContrasena),
            onPressed: () => setState(() => _showPassword = !_showPassword),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cerrar),
        ),
      ],
    );
  }
}

class _CredentialRow extends StatelessWidget {
  const _CredentialRow({
    required this.label,
    required this.value,
    required this.mask,
  });

  final String label;
  final String value;
  final bool mask;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final displayValue = mask ? '•' * value.length : value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 2),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            displayValue,
            style: AppTextStyles.bodyMedium.copyWith(
              fontFamily: mask ? null : 'monospace',
            ),
          ),
        ),
      ],
    );
  }
}
