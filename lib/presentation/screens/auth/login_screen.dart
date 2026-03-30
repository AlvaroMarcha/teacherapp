import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
          setState(() => _error = 'Usuario o contraseña incorrectos');
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showRecovery() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Acceder a credenciales'),
        content: const Text(
          'Se mostrarán tus credenciales guardadas. '
          '¿Continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ver'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final creds = await _authService.getCredentials();
    if (!mounted) return;

    if (creds.username == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay credenciales guardadas aún')),
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
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Teacher Finance',
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isFirstSetup
                        ? 'Crea tus credenciales de acceso'
                        : 'Accede a tu cuenta',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 32),

                  // ── Usuario ──────────────────────────────────
                  TextFormField(
                    controller: _userCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Usuario',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  // ── Contraseña ───────────────────────────────
                  TextFormField(
                    controller: _passCtrl,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
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
                      if (v == null || v.isEmpty) return 'Requerido';
                      if (_isFirstSetup && v.length < 4) {
                        return 'Mínimo 4 caracteres';
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
                          : Text(_isFirstSetup ? 'Crear acceso' : 'Entrar'),
                    ),
                  ),

                  // ── Recuperar contraseña ─────────────────────
                  if (!_isFirstSetup) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _showRecovery,
                      child: const Text('¿Olvidaste tu contraseña?'),
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

class _CredentialsDialog extends StatefulWidget {
  const _CredentialsDialog({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;

  @override
  State<_CredentialsDialog> createState() => _CredentialsDialogState();
}

class _CredentialsDialogState extends State<_CredentialsDialog> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tus credenciales'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CredentialRow(label: 'Usuario', value: widget.username, mask: false),
          const SizedBox(height: 12),
          _CredentialRow(
            label: 'Contraseña',
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
            label: Text(_showPassword ? 'Ocultar' : 'Mostrar contraseña'),
            onPressed: () => setState(() => _showPassword = !_showPassword),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
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
