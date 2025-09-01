// ignore_for_file: use_build_context_synchronously

import 'package:aplicacionlensys/evaluacion/providers/evaluaciones_provider.dart';
import 'package:aplicacionlensys/evaluacion/screens/principios.dart';
import 'package:aplicacionlensys/home/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/asociado_evaluacion.dart';
import '../models/empresa.dart';


class FormularioAsociadosScreen extends ConsumerStatefulWidget {
  final Empresa empresa;
  final String dimensionId;
  final String evaluacionId;

  const FormularioAsociadosScreen({
    super.key,
    required this.empresa,
    required this.dimensionId,
    required this.evaluacionId,
  });

  @override
  ConsumerState<FormularioAsociadosScreen> createState() =>
      _FormularioAsociadosScreenState();
}

class _FormularioAsociadosScreenState
    extends ConsumerState<FormularioAsociadosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<AsociadoEvaluacion> ejecutivos = [];
  List<AsociadoEvaluacion> gerentes = [];
  List<AsociadoEvaluacion> miembros = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _cargarAsociados();
  }

  Future<void> _cargarAsociados() async {
    final controller = ref.read(evaluacionProvider.notifier);
    await controller.cargarAsociados(widget.evaluacionId);

    final state = ref.read(evaluacionProvider);
    final asociados = state.asociados;

    setState(() {
      ejecutivos = asociados.where((a) => a.cargo == "E").toList();
      gerentes = asociados.where((a) => a.cargo == "G").toList();
      miembros = asociados.where((a) => a.cargo == "M").toList();
    });
  }

  Future<void> _mostrarDialogoAgregarAsociado() async {
  final nombreCtrl = TextEditingController();
  final antiguedadCtrl = TextEditingController();
  final puestoCtrl = TextEditingController();
  String cargoSeleccionado = 'E';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Nuevo Asociado',
            style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: antiguedadCtrl,
                decoration: const InputDecoration(
                  labelText: 'Antigüedad',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: puestoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Puesto',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: cargoSeleccionado,
                items: const [
                  DropdownMenuItem(value: "E", child: Text("Ejecutivo")),
                  DropdownMenuItem(value: "G", child: Text("Gerente")),
                  DropdownMenuItem(value: "M", child: Text("Miembro de Equipo")),
                ],
                onChanged: (value) => cargoSeleccionado = value!,
                decoration: const InputDecoration(
                  labelText: 'Cargo',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nombre = nombreCtrl.text.trim();
              final antiguedad = antiguedadCtrl.text.trim();
              final puesto = puestoCtrl.text.trim();
              if (nombre.isEmpty) return;

              final nuevo = AsociadoEvaluacion(
                id: const Uuid().v4(),
                nombreCompleto: nombre,
                cargo: cargoSeleccionado,
                antiguedad: antiguedad.isEmpty ? null : antiguedad,
                puesto: puesto.isEmpty ? null : puesto,
                evaluacionId: widget.evaluacionId,
              );

              final controller = ref.read(evaluacionProvider.notifier);
              await controller.agregarAsociado(nuevo);

              if (!mounted) return;
              Navigator.pop(context);
              _cargarAsociados();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003056),
              foregroundColor: Colors.white,
            ),
            child: const Text("Asociar empleado"),
          ),
        ],
      ),
    );
  }

  Widget _buildLista(List<AsociadoEvaluacion> lista) {
    if (lista.isEmpty) {
      return const Center(child: Text("SIN ASOCIADOS"));
    }
    return ListView.builder(
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final asociado = lista[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.person_outline, color: Color(0xFF003056)),
            title: Text(asociado.nombreCompleto, style: GoogleFonts.roboto()),
            subtitle: Text(asociado.cargo == "E"
                ? "EJECUTIVO"
                : asociado.cargo == "G"
                    ? "GERENTE"
                    : "MIEMBRO DE EQUIPO",
              style: GoogleFonts.roboto(color: Colors.grey),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PrincipiosScreen(
                    empresa: widget.empresa,
                    asociado: asociado,
                    dimensionId: widget.dimensionId,
                    evaluacionId: widget.evaluacionId,
                  ),
                ),
              ).then((_) => _cargarAsociados());
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const SizedBox(width: 300, child: ChatWidgetDrawer()),
      appBar: AppBar(
        backgroundColor: const Color(0xFF003056),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.empresa.nombre,
            style: GoogleFonts.roboto(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey.shade300,
          tabs: const [
            Tab(text: "EJECUTIVOS"),
            Tab(text: "GERENTES"),
            Tab(text: "MIEMBROS"),
          ],
        ),
      ),
     /* endDrawer: const DrawerLensys(),*/
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLista(ejecutivos),
          _buildLista(gerentes),
          _buildLista(miembros),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoAgregarAsociado(),
        backgroundColor: const Color(0xFF003056),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}
