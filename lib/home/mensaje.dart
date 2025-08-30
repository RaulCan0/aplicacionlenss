import 'dart:convert';

class Mensaje {
  final String id;
  final String userId;
  final String contenido; // antes "content"
  final DateTime createdAt;
  final List<String> imagenes; // URLs o rutas (puede estar vacío)

  Mensaje({
    required this.id,
    required this.userId,
    required this.contenido,
    required this.createdAt,
    this.imagenes = const [],
  });

  factory Mensaje.fromMap(Map<String, dynamic> map) {
    // soporte para distintos formatos: lista, json string o null
    final dynamic rawImgs = map['imagenes'] ?? map['images'];
    List<String> imgs = [];
    if (rawImgs != null) {
      if (rawImgs is String) {
        try {
          final decoded = json.decode(rawImgs);
          if (decoded is List) imgs = decoded.map((e) => e.toString()).toList();
        } catch (_) {
          // si no es JSON, usamos el string como una sola URL
          imgs = [rawImgs];
        }
      } else if (rawImgs is List) {
        imgs = rawImgs.map((e) => e.toString()).toList();
      }
    }

    return Mensaje(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      contenido: map['content'] as String, // mapeo desde la columna 'content'
      createdAt: DateTime.parse(map['created_at'] as String),
      imagenes: imgs,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'content': contenido, // se sigue enviando como 'content' a la BD
      'created_at': createdAt.toIso8601String(),
      'imagenes': imagenes, // guarda lista directamente (ajusta si tu DB necesita JSON)
    };
  }
}
