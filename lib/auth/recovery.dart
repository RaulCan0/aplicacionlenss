// lib/screens/recovery.dart
import 'package:aplicacionlensys/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecoveryScreen extends ConsumerStatefulWidget {
  const RecoveryScreen({super.key});
  @override
  ConsumerState<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends ConsumerState<RecoveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loadingLocal = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final stored = await ref.read(authNotifierProvider.notifier).loadSavedCredentials();
      if (stored != null) _email.text = stored['email'] ?? '';
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loadingLocal = true);
    final notifier = ref.read(authNotifierProvider.notifier);
    final online = (ref.read(authNotifierProvider).online);
    if (!online) {
      setState(() => _loadingLocal = false);
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Sin conexión'),
          content: const Text('No hay internet. ¿Deseas intentar recuperar usando credenciales guardadas localmente?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí')),
          ],
        ),
      );
      if (ok != true) return;
      final stored = await notifier.loadSavedCredentials();
      setState(() => _loadingLocal = false);
      if (stored != null && stored['email'] == _email.text.trim()) {
        if (!mounted) return;
        showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Recuperado localmente'), content: const Text('Se encontraron credenciales guardadas para este correo.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ok'))]));
      } else {
        if (!mounted) return;
        showDialog(context: context, builder: (_) => AlertDialog(title: const Text('No encontrado'), content: const Text('No hay credenciales guardadas para este correo.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ok'))]));
      }
      return;
    }

    final res = await notifier.sendPasswordRecovery(_email.text.trim());
    setState(() => _loadingLocal = false);

    if (res.ok) {
      if (!mounted) return;
      showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Enviado'), content: Text(res.message), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ok'))]));
    } else {
      if (!mounted) return;
      showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Error'), content: Text(res.message), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ok'))]));
    }
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: LayoutBuilder(builder: (context, constraints) {
        final narrow = constraints.maxWidth < 600;
        return SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: narrow ? 600 : 800),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _loadingLocal || state.loading
                        ? const Center(child: CircularProgressIndicator())
                        : Column(mainAxisSize: MainAxisSize.min, children: [
                            const Text('Recuperar contraseña', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Form(
                              key: _formKey,
                              child: Column(children: [
                                TextFormField(
                                  controller: _email,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(labelText: 'Correo', prefixIcon: Icon(Icons.email)),
                                  validator: (v) => (v == null || v.isEmpty) ? 'Ingresa el correo' : null,
                                ),
                                const SizedBox(height: 16),
                                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _submit, child: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Recuperar')))),
                                if (state.error != null) ...[
                                  const SizedBox(height: 12),
                                  Text(state.error!, style: const TextStyle(color: Colors.red)),
                                ],
                              ]),
                            ),
                          ]),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
