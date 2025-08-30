// lib/screens/login.dart
import 'package:aplicacionlensys/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _remember = true;

  @override
  void initState() {
    super.initState();
    // Prefill si hay cred guardadas
    Future.microtask(() async {
      final stored = await ref.read(authNotifierProvider.notifier).loadSavedCredentials();
      if (stored != null) {
        _emailController.text = stored['email'] ?? '';
        _passController.text = stored['password'] ?? '';
      }
    });
  }

  Future<void> _showNoConnectionDialogAndMaybeOffline() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sin conexión'),
        content: const Text('No hay conexión a internet. ¿Deseas continuar en modo offline?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí')),
        ],
      ),
    );
    if (ok == true) {
      await _submit(allowOffline: true);
    }
  }

  Future<void> _submit({bool allowOffline = false}) async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(authNotifierProvider.notifier);

    // Intentamos signIn. Si no hay conexión y no permitimos offline,
    // el notifier devolverá message 'No hay conexión...' y acá mostramos dialog.
    final email = _emailController.text.trim();
    final pass = _passController.text;

    final res = await notifier.signIn(email, pass, remember: _remember, allowOffline: allowOffline);

    if (!res.ok && res.message.contains('No hay conexión')) {
      // muestra dialog que pregunta si continuar offline
      await _showNoConnectionDialogAndMaybeOffline();
      return;
    }

    if (res.ok) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      if (!mounted) return;
      showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Error'), content: Text(res.message), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))]));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authNotifierProvider);
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        final narrow = constraints.maxWidth < 600;
        return SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: narrow ? 600 : 800),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: state.loading
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Iniciar sesión', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _emailController,
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
                                      controller: _passController,
                                      obscureText: true,
                                      decoration: const InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock)),
                                      validator: (v) => (v == null || v.isEmpty) ? 'Ingresa la contraseña' : null,
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Checkbox(value: _remember, onChanged: (v) => setState(() => _remember = v ?? true)),
                                        const Text('Recordar credenciales'),
                                        const Spacer(),
                                        TextButton(onPressed: () => Navigator.of(context).pushNamed('/recovery'), child: const Text('Olvidé mi contraseña')),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _submit(), child: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Entrar')))),
                                    const SizedBox(height: 8),
                                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('¿No tienes cuenta?'), TextButton(onPressed: () => Navigator.of(context).pushNamed('/register'), child: const Text('Crear cuenta'))]),
                                    if (state.error != null) ...[
                                      const SizedBox(height: 12),
                                      Text(state.error!, style: const TextStyle(color: Colors.red)),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
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
