
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'supabase_service.dart';
// Provider para obtener el progreso por cargo en una dimensión
final dimensionCargoProvider = FutureProvider.family<ProgresoPorCargo, ({String evaluacionId, String dimensionId, Cargo cargo})>((ref, params) async {
  final supabase = SupabaseService();
  // Aquí deberías implementar la lógica real para obtener el progreso por cargo
  // Ejemplo básico:
  final avance = await supabase.obtenerProgresoDimension(params.evaluacionId, params.dimensionId);
  // Puedes agregar más lógica para filtrar por cargo si tu modelo lo permite
  return ProgresoPorCargo(
    avance: avance,
    promedio: avance * 5,
    calificados: (avance * 100).round(),
    totalComportamientos: 100,
  );
});

class ProgresoPorCargo {
  final double avance;
  final double promedio;
  final int calificados;
  final int totalComportamientos;

  ProgresoPorCargo({
    required this.avance,
    required this.promedio,
    required this.calificados,
    required this.totalComportamientos,
  });
}


class ProgresoDimensionCargos extends ConsumerWidget {
  final String evaluacionId;
  final String dimensionId;
  const ProgresoDimensionCargos({
    super.key,
    required this.evaluacionId,
    required this.dimensionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget item(Cargo cargo, String label, IconData icon) {
      final async = ref.watch(dimensionCargoProvider((
        evaluacionId: evaluacionId,
        dimensionId: dimensionId,
        cargo: cargo,
      )));
      return async.when(
        data: (p) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 18),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 6),
            LinearProgressIndicator(value: p.avance.clamp(0, 1)),
            const SizedBox(height: 4),
            Text('Promedio ${p.promedio.toStringAsFixed(2)} / 5 • '
                '${p.calificados}/${p.totalComportamientos} comp.'),
          ],
        ),
        loading: () => const LinearProgressIndicator(),
        error: (e, _) => Text('Error: $e'),
      );
    }

    return Column(
      children: [
        item(Cargo.ejecutivo, 'Ejecutivo', Icons.workspace_premium),
        const SizedBox(height: 12),
        item(Cargo.gerente, 'Gerente', Icons.manage_accounts),
        const SizedBox(height: 12),
        item(Cargo.miembro, 'Miembro de Equipo', Icons.group),
      ],
    );
  }
}
