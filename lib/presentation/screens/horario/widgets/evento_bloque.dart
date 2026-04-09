import 'package:flutter/material.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../domain/models/evento_calendario.dart';

/// Bloque visual de un evento en el calendario.
/// Usado en la vista Día, lista del día y timeline semanal.
class EventoBloque extends StatelessWidget {
  const EventoBloque({
    super.key,
    required this.evento,
    required this.onTap,
    this.compact = false,
  });

  final EventoCalendario evento;
  final VoidCallback onTap;

  /// Si true, muestra versión compacta (solo hora + título, sin subtítulo).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = evento.color;
    final opacity = evento.esCancelada ? 0.5 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Material(
        color: color.withOpacity(compact ? 0.15 : 0.12),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(color: color, width: 3),
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 4 : 8,
              vertical: compact ? 2 : 8,
            ),
            child: compact
                ? _CompactContent(evento: evento, color: color)
                : _FullContent(evento: evento, color: color),
          ),
        ),
      ),
    );
  }
}

class _CompactContent extends StatelessWidget {
  const _CompactContent({required this.evento, required this.color});
  final EventoCalendario evento;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Una sola línea: hora + título truncado. Sin Row/Spacer que desborde.
    final icon = evento.esCancelada
        ? '✕ '
        : evento.estaConfirmada
            ? '✓ '
            : evento.estaPendiente
                ? '⏰ '
                : '';
    return Text(
      '$icon${evento.horaInicio} ${evento.titulo}',
      style: AppTextStyles.labelSmall.copyWith(color: color, fontSize: 9.5),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _FullContent extends StatelessWidget {
  const _FullContent({required this.evento, required this.color});
  final EventoCalendario evento;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              '${evento.horaInicio} – ${evento.horaFin}',
              style: AppTextStyles.labelSmall.copyWith(color: color),
            ),
            const Spacer(),
            if (evento.esCancelada)
              Icon(Icons.cancel_outlined, size: 14, color: color)
            else if (evento.estaPendiente)
              Icon(Icons.schedule_outlined, size: 14, color: color)
            else if (evento.estaConfirmada)
              Icon(Icons.check_circle_outline, size: 14, color: color),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          evento.titulo,
          style: AppTextStyles.bodyMedium.copyWith(
            decoration: evento.esCancelada ? TextDecoration.lineThrough : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (evento.fuenteNombre != null && evento.fuenteNombre != evento.titulo)
          Text(
            evento.fuenteNombre!,
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        if (evento.cobro != null) ...[
          const SizedBox(height: 2),
          Text(
            CurrencyUtils.formatCompact(evento.cobro!),
            style: AppTextStyles.labelSmall.copyWith(color: color),
          ),
        ],
      ],
    );
  }
}
