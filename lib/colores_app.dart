import 'package:flutter/material.dart';

class Coloresapp {
  static const Color lensys = Color(0xFF0E2238);      // Azul AppBar (14,34,56)
  static const Color E = Color(0xFFFF9800);           // Ejecutivo: Naranja
  static const Color G = Color(0xFF4CAF50);           // Gerente: Verde
  static const Color mE = Color(0xFF1976D2);           // Miembro: Azul
  static const Map<String, Color> coloresPorDimension = {
    'IMPULSORES CULTURALES': Color.fromARGB(255, 122, 141, 245),   // azul
    'MEJORA CONTINUA': Color.fromARGB(255, 67, 78, 141),           // azul oscuro
    'ALINEAMIENTO EMPRESARIAL': Color.fromARGB(255, 14, 24, 78),   // azul más oscuro
  };
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color darkBackground = Color(0xFF121212);           // Gris
}




// Estilos de texto
const TextStyle ch = TextStyle(
  fontSize: 13,
  fontFamily: 'Roboto',
);

const TextStyle m = TextStyle(
  fontSize: 15,
  fontFamily: 'Roboto',
);

const TextStyle g = TextStyle(
  fontSize: 17,
  fontFamily: 'Roboto',
);
