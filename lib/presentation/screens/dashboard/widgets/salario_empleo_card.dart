import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../domain/models/empleo_nomina.dart';
import '../../../../domain/models/fuente.dart';
import '../../../providers/theme_provider.dart';
import '../../fuentes/widgets/nomina_mensual_dialog.dart';

/// Card del dashboard que muestra el salario del mes de una fuente de empleo.
class SalarioEmpleoCard extends ConsumerWidget {
  const SalarioEmpleoCard({
    super.key,
    required this.fuente,
    required this.salarioBase,
    this.nomina,
  });

  final Fuente fuente;
  final double salarioBase;
  final EmpleoNomina? nomina;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(appLocalizationsProvider);
    final locale = ref.watch(localeProvider);
    final color = fuente.flutterColor;
    final colorLight = color.withValues(alpha: 0.15);
    final tieneNomina = nomina != null;
    final hoy = DateTime.now();
    final mesLabel =
        DateFormat('MMMM yyyy', locale.locale.toString()).format(hoy);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: tieneNomina
                ? colorLight
                : Colors.orange.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            tieneNomina
                ? Icons.account_balance_wallet_rounded
                : Icons.warning_amber_rounded,
            color: tieneNomina ? color : Colors.orange,
          ),
        ),
        title: Text(
          '${l.nominaMensual} (${fuente.nombre})',
          style: AppTextStyles.titleSmall,
        ),
        subtitle: tieneNomina
            ? Text(
                '$mesLabel · ${CurrencyUtils.formatCompact(nomina!.salario)}',
                style: AppTextStyles.bodySmall,
              )
            : Text(
                '${l.sinNominaIntroducida} · ${CurrencyUtils.formatCompact(salarioBase)} ${l.valorPorDefecto}',
                style: AppTextStyles.bodySmall
                    .copyWith(color: Colors.orange.shade700),
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: tieneNomina ? l.editarNomina : l.introducirNomina,
              icon: Icon(
                tieneNomina ? Icons.edit_rounded : Icons.add_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onPressed: () => showNominaMensualDialog(
                context,
                fuenteId: fuente.id,
                anio: hoy.year,
                mes: hoy.month,
                salarioDefault: salarioBase,
                nominaActual: nomina,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
        onTap: () => context.push(
          '${AppRoutes.horasExtra}?fuenteId=${fuente.id}',
        ),
      ),
    );
  }
}
