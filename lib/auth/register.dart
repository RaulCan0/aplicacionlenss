// lib/screens/register.dart
import 'package:aplicacionlensys/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loadingLocal = false;
  bool _remember = true;

  @override
  void initState() {
    super.initState();
    // prefill with saved email if existe
    Future.microtask(() async {
      final stored = await ref.read(authNotifierProvider.notifier).loadSavedCredentials();
      if (stored != null) {
        _email.text = stored['email'] ?? '';
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loadingLocal = true);
    final notifier = ref.read(authNotifierProvider.notifier);
    final res = await notifier.register(_email.text.trim(), _pass.text, remember: _remember);
    setState(() => _loadingLocal = false);

    if (res.ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message)));
      Navigator.of(context).pop();
    } else {
      if (!mounted) return;
      showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Error'), content: Text(res.message), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))]));
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
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
                            const Text('Registro', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Form(
                              key: _formKey,
                              child: Column(children: [
                                TextFormField(
                                  controller: _email,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(labelText: 'Correo', prefixIcon: Icon(Icons.email)),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Ingresa el correo';
                                    if (!v.contains('@')) return 'Correo inválido';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _pass,
                                  obscureText: true,
                                  decoration: const InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock)),
                                  validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                                ),
                                const SizedBox(height: 12),
                                Row(children: [Checkbox(value: _remember, onChanged: (v) => setState(() => _remember = v ?? true)), const Text('Recordar credenciales')]),
                                const SizedBox(height: 12),
                                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _submit, child: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Crear cuenta')))),
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
