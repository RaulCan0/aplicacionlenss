import 'package:flutter/material.dart';

/// Termómetro vertical 0..1000 con marca actual.
class Termometro1000 extends StatelessWidget {
  final double valor; // 0..1000
  const Termometro1000({super.key, required this.valor});

  @override
  Widget build(BuildContext context) {
    final pct = (valor / 1000).clamp(0.0, 1.0);
    return Column(
      children: [
        const Text('0 - 1000'),
        const SizedBox(height: 8),
        SizedBox(
          height: 240,
          width: 36,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black26),
                ),
              ),
              FractionallySizedBox(
                heightFactor: pct,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              Positioned(
                bottom: (240 * pct) - 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((0.6 * 255).toInt()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(valor.toStringAsFixed(0), style: const TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
