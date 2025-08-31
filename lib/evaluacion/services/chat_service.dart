import 'package:aplicacionlensys/home/mensaje.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final _client = Supabase.instance.client;

  /// Envía un mensaje a Supabase
  Future<void> sendMessage(String userId, String content) async {
    await _client
        .from('messages')
        .insert({
          'user_id': userId,
          'content': content,
        });
  }
  /// Stream de mensajes ordenados por fecha
  Stream<List<Mensaje>> messageStream() {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map((maps) =>
            maps.map((m) => Mensaje.fromMap(m)).toList());
  }
}