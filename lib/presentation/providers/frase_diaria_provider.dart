import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/frase_diaria_service.dart';

/// Provider que obtiene la frase motivacional del día.
final fraseDiariaProvider = FutureProvider<String>((ref) async {
  return await FraseDiariaService.getFraseDelDia();
});
