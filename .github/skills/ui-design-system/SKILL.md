---
name: ui-design-system
description: Sistema de diseño para Teacher Finance App — tokens AppColors/AppTextStyles, tema Material 3, patrones de pantallas, formularios, navegación GoRouter, TableCalendar y convenciones de layout.
---

# Skill: UI Design System

Sistema de diseño y patrones de widgets para Teacher Finance App.

## Tokens de color (`AppColors`)

```dart
// lib/core/constants/app_colors.dart

// Colores de fuente (del informe de diseño)
AppColors.around       // #2563EB — Empleo fijo (alrededor)
AppColors.angels       // #6366F1 — Academia Angels
AppColors.particulares // #16A34A — Alumnos particulares

// Sesiones (calendario)
AppColors.sesionRecurrente  // azul (Around)
AppColors.sesionParticular  // verde (alumno propio)
AppColors.sesionUnica       // morado (clase puntual)
AppColors.sesionCancelada   // gris

// Cobros
AppColors.cobroPendiente      // amber
AppColors.cobroPendienteLight // amber claro (background)
AppColors.cobroCobrado        // verde
AppColors.cobroParcial        // sky blue

// Helpers dinámicos
AppColors.forFuenteTipo(FuenteTipo tipo)  // → color de fuente
AppColors.lightForFuenteTipo(tipo)         // → versión clara para bg
AppColors.forEstadoCobro(EstadoCobro e)   // → color de estado
```

---

## Tipografía (`AppTextStyles`)

```dart
// lib/core/constants/app_text_styles.dart

// Jerarquía de títulos
AppTextStyles.displayLarge  // 32sp bold — grandes cifras del dashboard
AppTextStyles.titleLarge    // 22sp bold
AppTextStyles.titleMedium   // 18sp semibold
AppTextStyles.titleSmall    // 16sp semibold

// Cuerpo
AppTextStyles.bodyLarge     // 16sp regular
AppTextStyles.bodyMedium    // 14sp regular
AppTextStyles.bodySmall     // 12sp regular

// Labels y etiquetas
AppTextStyles.labelLarge    // 14sp medium
AppTextStyles.labelMedium   // 12sp medium
AppTextStyles.labelSmall    // 11sp medium — subtítulos de sección (caps)
AppTextStyles.caption       // 12sp, gris

// Importes (financieros)
AppTextStyles.amountLarge   // 28sp bold — importes principales
AppTextStyles.amountMedium  // 20sp semibold
AppTextStyles.amountSmall   // 16sp semibold — importes compactos
```

---

## Tema (`AppTheme`)

```dart
// lib/core/theme/app_theme.dart
MaterialApp.router(
  theme: AppTheme.light,  // Material 3, colorScheme basado en primary (#2563EB)
  ...
)
```

Fragmento del tema:
- **useMaterial3**: `true`
- **colorScheme**: `ColorScheme.fromSeed(seedColor: AppColors.primary)`
- **CardTheme**: `elevation: 0`, `border: Border`, `borderRadius: 16`
- **InputDecoration**: `filled: true`, `border: OutlineInputBorder(radius: 12)`
- **AppBar**: `centerTitle: false`, `elevation: 0`, `scrolledUnderElevation: 1`

---

## Patrones de pantalla

### Pantalla estándar con lista reactiva
```dart
class MiScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(miProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Título')),
      body: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) => items.isEmpty
            ? const _EmptyState()
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) => _ItemTile(item: items[i]),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.miForm),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### Card de resumen (estilo dashboard)
```dart
Card(
  margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Etiqueta', style: AppTextStyles.labelMedium),
        const SizedBox(height: 4),
        Text(CurrencyUtils.format(monto), style: AppTextStyles.amountLarge),
      ],
    ),
  ),
)
```

### Indicador de color de fuente
```dart
Container(
  width: 12,
  height: 12,
  decoration: BoxDecoration(
    color: AppColors.forFuenteTipo(fuente.tipo),
    shape: BoxShape.circle,
  ),
)
```

### Chip de estado de cobro
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  decoration: BoxDecoration(
    color: AppColors.forEstadoCobro(cobro.estado).withOpacity(0.12),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.forEstadoCobro(cobro.estado)),
  ),
  child: Text(
    cobro.estado.value,
    style: AppTextStyles.labelSmall.copyWith(
      color: AppColors.forEstadoCobro(cobro.estado),
    ),
  ),
)
```

---

## Formularios — Reglas de estilo obligatorias

### Campos de selección (fecha, hora, pickers)

**SIEMPRE** usar `GestureDetector` + `InputDecorator` para campos tappables (fecha, hora, etc.), **NUNCA** usar `ListTile` dentro de formularios. Esto garantiza que todos los campos tengan el mismo borde, padding y estilo que los `TextFormField` y `DropdownButtonFormField`.

```dart
// ✅ CORRECTO — InputDecorator con InputDecoration
GestureDetector(
  onTap: _pickFecha,
  child: InputDecorator(
    decoration: const InputDecoration(
      labelText: 'Fecha',
      prefixIcon: Icon(Icons.calendar_today_outlined),
      suffixIcon: Icon(Icons.chevron_right),
    ),
    child: Text(AppDateUtils.formatFullDate(_fecha)),
  ),
),

// ❌ INCORRECTO — ListTile rompe la consistencia visual
ListTile(
  title: Text('Fecha', style: AppTextStyles.labelMedium),
  trailing: Text('30/03/2026'),
  contentPadding: EdgeInsets.zero,
  onTap: _pickFecha,
),
```

### Campos de hora en fila (inicio / fin)
```dart
Row(
  children: [
    Expanded(
      child: GestureDetector(
        onTap: () => _pickHora(isInicio: true),
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Inicio',
            prefixIcon: Icon(Icons.schedule_outlined),
          ),
          child: Text(_formatTime(_horaInicio)),
        ),
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: GestureDetector(
        onTap: () => _pickHora(isInicio: false),
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Fin',
            prefixIcon: Icon(Icons.schedule_outlined),
          ),
          child: Text(_formatTime(_horaFin)),
        ),
      ),
    ),
  ],
),
```

### Helper de formato de hora
```dart
String _formatTime(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
```

### Importe auto-calculado (disabled con botón de edición)
Cuando un campo tiene valor auto-calculado (tarifa del alumno, tarifa global), hacerlo `enabled: false` por defecto y añadir un `IconButton` de edición:
```dart
TextFormField(
  controller: _importeCtrl,
  enabled: _importeEditable,
  decoration: InputDecoration(
    labelText: 'Importe (€)',
    prefixIcon: const Icon(Icons.euro_rounded),
    helperText: _importeHelper,
    suffixIcon: _importeEditable
        ? null
        : IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar importe',
            onPressed: () => setState(() => _importeEditable = true),
          ),
  ),
),
```

### Selector de días de la semana (FilterChip)
```dart
static const _dias = [
  (1, 'L'), (2, 'M'), (3, 'X'), (4, 'J'), (5, 'V'), (6, 'S'), (7, 'D'),
];

Wrap(
  spacing: 8,
  children: _dias.map((d) {
    final (num, label) = d;
    final selected = _diasSemana.contains(num);
    return FilterChip(
      label: Text(label),
      selected: selected,
      shape: const StadiumBorder(), // OBLIGATORIO — ignora chipTheme
      onSelected: (v) => setState(() {
        if (v) _diasSemana.add(num);
        else _diasSemana.remove(num);
      }),
    );
  }).toList(),
),
```

### Reglas generales de espaciado en formularios
- **Entre campos**: `const SizedBox(height: 12)`
- **Antes de secciones (divider, título)**: `const SizedBox(height: 24)`
- **Después de divider/título**: `const SizedBox(height: 16)`
- **Antes del botón final**: `const SizedBox(height: 32)`
- **Padding del ListView**: `const EdgeInsets.all(16)`
- **FilterChip siempre con**: `shape: const StadiumBorder()`

### Chips y border radius globales
- **Chips**: `StadiumBorder()` explícito en cada `FilterChip` (M3 ignora `chipTheme.shape`)
- **Border radius global**: `14` para cards, bottom sheets, dialogs
- **Input border radius**: `12` (definido en `AppTheme.inputDecorationTheme`)

---

## Navegación

```dart
// Push (añadir al historial)
context.push(AppRoutes.alumnoForm);
context.push(AppRoutes.alumnoDetalle.replaceFirst(':id', alumnoId));

// Go (reemplazar historial)
context.go(AppRoutes.dashboard);

// Pop
context.pop();
Navigator.of(context).pop();  // equivalente, funciona también
```

### Rutas con parámetros
```dart
// Definir en app_router.dart:
GoRoute(
  path: '/alumnos/:id',
  builder: (context, state) => AlumnoDetalleScreen(
    alumnoId: state.pathParameters['id']!,
  ),
),

// Navegar:
context.push('/alumnos/$alumnoId');
```

---

## Sliding (cobros)

```dart
// flutter_slidable: swipe para acciones rápidas
Slidable(
  key: ValueKey(cobro.id),
  endActionPane: ActionPane(
    motion: const DrawerMotion(),
    children: [
      SlidableAction(
        onPressed: (_) => _marcarCobrado(cobro.id),
        backgroundColor: AppColors.cobroCobrado,
        foregroundColor: Colors.white,
        icon: Icons.check,
        label: 'Cobrado',
        borderRadius: BorderRadius.circular(12),
      ),
    ],
  ),
  child: CobroTile(cobro: cobro),
)
```

---

## Localización

```dart
// Fechas en español
import 'package:intl/intl.dart';
final fmt = DateFormat('d MMMM yyyy', 'es_ES');
fmt.format(DateTime.now());  // "15 julio 2025"

// O usar las utilidades del proyecto:
AppDateUtils.formatFullDate(fecha)  // "15 julio 2025"
AppDateUtils.formatMonth(fecha)     // "julio 2025"
AppDateUtils.formatShortDate(fecha) // "15 jul"
```

```dart
// Moneda
CurrencyUtils.format(1840.0)        // "€ 1.840,00"
CurrencyUtils.formatCompact(1840.0) // "€1.840"
```

---

## TableCalendar (pantalla horario)

```dart
TableCalendar(
  locale: 'es_ES',
  calendarFormat: CalendarFormat.week,
  focusedDay: _focusedDay,
  firstDay: DateTime(2024),
  lastDay: DateTime(2030),
  calendarStyle: CalendarStyle(
    todayDecoration: BoxDecoration(
      color: AppColors.primary.withOpacity(0.2),
      shape: BoxShape.circle,
    ),
    selectedDecoration: BoxDecoration(
      color: AppColors.primary,
      shape: BoxShape.circle,
    ),
  ),
  onDaySelected: (selected, focused) { ... },
  eventLoader: (day) => _sesionesDelDia(day),
)
```

---

## Convenciones de layout

- **Padding estándar**: `EdgeInsets.all(16)` para pantallas
- **Spacing entre secciones**: `SizedBox(height: 24)`
- **Spacing entre elementos de formulario**: `SizedBox(height: 12)`
- **Card margin**: `EdgeInsets.fromLTRB(16, 6, 16, 6)`
- **Card padding interno**: `EdgeInsets.all(20)` para cards de resumen, `EdgeInsets.all(16)` para cards secundarias
- **BorderRadius estándar**: `12` (inputs), `16` (cards), `20` (chips)

---

## Empty states

```dart
class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(message, style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }
}
```

Ver [references/widget-patterns.md](references/widget-patterns.md) para más ejemplos de widgets.
