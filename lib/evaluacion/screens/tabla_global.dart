import 'package:flutter/material.dart';

class TablaGlobalScreen extends StatefulWidget {
  const TablaGlobalScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TablaGlobalScreenState createState() => _TablaGlobalScreenState();
}

class _TablaGlobalScreenState extends State<TablaGlobalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Tabla Global'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'TablaScoreGlobal'),
            Tab(text: 'TabasHingo'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          Center(child: Text('Contenido de TablaScoreGlobal')),
          Center(child: Text('Contenido de TabasHingo')),
        ],
      ),
    );
  }
}