// ignore_for_file: use_build_context_synchronously

import 'package:aplicacionlensys/evaluacion/services/chat_service.dart';
import 'package:aplicacionlensys/home/mensaje.dart';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class ChatWidgetDrawer extends StatefulWidget {
  const ChatWidgetDrawer({super.key});

  @override
  State<ChatWidgetDrawer> createState() => _ChatWidgetDrawerState();
}

class _ChatWidgetDrawerState extends State<ChatWidgetDrawer> {
  final _chatService = ChatService();
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  late final String _myUserId;

  final Color chatColor = Colors.teal;
  final Color receivedColor = Colors.grey.shade200;

  @override
  void initState() {
    super.initState();
    _myUserId = Supabase.instance.client.auth.currentUser!.id;

    // Hacer scroll automático cuando llegan mensajes nuevos
    _chatService.messageStream().listen((messages) {
      if (mounted && messages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });
  }

  Future<void> _tomarYSubirFoto() async {
    final picker = ImagePicker();
    final XFile? foto =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (foto != null) {
      final file = File(foto.path);
      final fileName =
          'chat_${DateTime.now().millisecondsSinceEpoch}_$_myUserId.jpg';

      // Feedback de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final res = await Supabase.instance.client.storage
          .from('chats')
          .upload(fileName, file);
      Navigator.of(context).pop(); // Cerrar el dialogo de carga

      if (res.isNotEmpty) {
        final url = Supabase.instance.client.storage
            .from('chats')
            .getPublicUrl(fileName);
        await _chatService.sendMessage(_myUserId, url);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo subir la foto')),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final drawerWidth =
        MediaQuery.of(context).size.width.clamp(280, 380).toDouble();

    return Drawer(
      width: drawerWidth,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: chatColor,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const Text(
                  'Chat',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chat_bubble_outline, color: Colors.white),
              ],
            ),
          ),

          /// StreamBuilder de mensajes
          Expanded(
            child: StreamBuilder<List<Mensaje>>(
              stream: _chatService.messageStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay mensajes aún',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(6),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.userId == _myUserId;
                    final isImage = msg.contenido.startsWith('http');

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        padding: const EdgeInsets.all(10),
                        constraints:
                            BoxConstraints(maxWidth: drawerWidth * 0.75),
                        decoration: BoxDecoration(
                          color: isMe ? chatColor : receivedColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            isImage
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      msg.contenido,
                                      fit: BoxFit.cover,
                                      width: drawerWidth * 0.65,
                                    ),
                                  )
                                : Text(
                                    msg.contenido,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isMe
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('HH:mm').format(msg.createdAt),
                              style: TextStyle(
                                fontSize: 9,
                                color: isMe
                                    ? Colors.white70
                                    : Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),

          /// Caja de texto + botones
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.camera_alt, color: chatColor),
                  onPressed: _tomarYSubirFoto,
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Mensaje...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    onSubmitted: (text) async {
                      final trimmed = text.trim();
                      if (trimmed.isNotEmpty) {
                        await _chatService.sendMessage(_myUserId, trimmed);
                        _textController.clear();
                        WidgetsBinding.instance
                            .addPostFrameCallback((_) => _scrollToBottom());
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: chatColor),
                  onPressed: () async {
                    final text = _textController.text.trim();
                    if (text.isNotEmpty) {
                      await _chatService.sendMessage(_myUserId, text);
                      _textController.clear();
                      WidgetsBinding.instance
                          .addPostFrameCallback((_) => _scrollToBottom());
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
