# UI Design System — Patrones de widgets

## Widgets de uso frecuente

### InfoRow — par etiqueta/valor
```dart
// Usado en cards de detalle (EmpleoTab, CobroDetalleScreen, etc.)
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const InfoRow({super.key, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
```

### FuenteColorDot — círculo de color de fuente
```dart
class FuenteColorDot extends StatelessWidget {
  final FuenteTipo tipo;
  final double size;
  const FuenteColorDot({super.key, required this.tipo, this.size = 12});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.forFuenteTipo(tipo),
        shape: BoxShape.circle,
      ),
    );
  }
}
```

### EstadoChip — chip de estado cobro/sesión
```dart
class EstadoChip extends StatelessWidget {
  final String label;
  final Color color;
  const EstadoChip({super.key, required this.label, required this.color});

  factory EstadoChip.cobro(EstadoCobro estado) => EstadoChip(
    label: estado.value,
    color: AppColors.forEstadoCobro(estado),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
    );
  }
}
```

---

## Patrones de formulario

### Formulario estándar con validación
```dart
class _MiFormScreen extends ConsumerStatefulWidget { ... }

class _MiFormState extends ConsumerState<_MiFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();

  @override
  void dispose() {
    _nombreCtrl.dispose();  // ← SIEMPRE dispose controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo registro'),
        actions: [
          TextButton(onPressed: _guardar, child: const Text('Guardar')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombreCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'El nombre es obligatorio'
                  : null,
            ),
            const SizedBox(height: 12),
            // más campos...
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _guardar,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    // ... guardar
    if (mounted) Navigator.of(context).pop();
  }
}
```

---

## Patrones de navegación con resultado

```dart
// Navegar y esperar resultado
final result = await Navigator.of(context).push<bool>(
  MaterialPageRoute(builder: (_) => const AlumnoFormScreen()),
);
if (result == true) {
  // El usuario guardó algo
  ref.invalidate(alumnosProvider);
}

// Con GoRouter push y resultado (limitado)
context.push(AppRoutes.alumnoForm);  // no retorna resultado directamente
```

---

## Shimmer (loading placeholder)

```dart
import 'package:shimmer/shimmer.dart';

// Loading state para listas
class _LoadingList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Confirmación antes de acción destructiva

```dart
Future<bool> _confirmarEliminar(BuildContext context, String nombre) async {
  return await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Eliminar'),
          content: Text('¿Eliminar a $nombre? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      ) ??
      false;
}
```

---

## BottomSheet para acciones rápidas

```dart
// Confirmar sesión desde el horario (flujo de 3 toques)
void _mostrarConfirmacion(BuildContext context, SesionRecurrente sesion) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        top: 16, left: 16, right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('¿Se realizó la sesión?', style: AppTextStyles.titleMedium),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('No / Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    context.push(AppRoutes.registroSesion);
                  },
                  child: const Text('Sí, confirmar'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
```

---

## Convenciones de accesibilidad

- Usar `Semantics` en iconos sin texto
- Asegurar contraste ≥ 4.5:1 en texto sobre colores de fuente
- `InkWell` > `GestureDetector` para hit areas correctas
- Minimum tap area: 48×48 dp (`MaterialTapTargetSize.padded`)
