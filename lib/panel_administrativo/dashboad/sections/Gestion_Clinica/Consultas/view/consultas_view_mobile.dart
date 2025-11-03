import 'package:flutter/material.dart';
import '../controller/consultas_controller_mobile.dart';
import '../model/consulta_model.dart';
import 'consulta_form_mobile.dart';

class ConsultasViewMobile extends StatefulWidget {
  const ConsultasViewMobile({super.key});

  @override
  State<ConsultasViewMobile> createState() => _ConsultasViewMobileState();
}

class _ConsultasViewMobileState extends State<ConsultasViewMobile> {
  final ConsultasControllerMobile _controller = ConsultasControllerMobile();
  List<Consulta> _consultas = [];
  List<Consulta> _filteredConsultas = [];
  bool _isLoading = true;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _loadConsultas();
  }

  Future<void> _loadConsultas() async {
    setState(() => _isLoading = true);
    final consultas = await _controller.getConsultas();
    if (!mounted) return;
    setState(() {
      _consultas = consultas;
      _filteredConsultas = _applyFilter(_searchTerm);
      _isLoading = false;
    });
    if (consultas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay consultas registradas.')),
      );
    }
  }

  List<Consulta> _applyFilter(String query) {
    if (query.isEmpty) return List<Consulta>.from(_consultas);
    final lowerQuery = query.toLowerCase();
    return _consultas
        .where(
          (consulta) =>
              consulta.motivoConsulta.toLowerCase().contains(lowerQuery) ||
              consulta.estadoConsulta.toLowerCase().contains(lowerQuery) ||
              consulta.historiaClinicaId.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  void _handleSearch(String value) {
    setState(() {
      _searchTerm = value;
      _filteredConsultas = _applyFilter(value);
    });
  }

  Future<void> _handleCreateConsulta() async {
    var created = false;
    await showDialog<void>(
      context: context,
      builder: (context) => ConsultaFormMobile(
        onSave: (consulta) async {
          final messenger = ScaffoldMessenger.of(context);
          try {
            final nextId = await _controller.getNextIdConsulta();
            final nuevaConsulta = Consulta(
              idConsulta: int.tryParse(nextId) ?? 0,
              historiaClinicaId: consulta.historiaClinicaId,
              estudianteId: consulta.estudianteId,
              docenteValidadorId: consulta.docenteValidadorId,
              fechaConsulta: consulta.fechaConsulta,
              motivoConsulta: consulta.motivoConsulta,
              historiaEnfermedadActual: consulta.historiaEnfermedadActual,
              estadoConsulta: consulta.estadoConsulta,
            );
            await _controller.agregarConsulta(nuevaConsulta);
            created = true;
          } catch (e, st) {
            debugPrint('Error agregando consulta (mobile): $e\n$st');
            if (mounted) {
              messenger.showSnackBar(
                SnackBar(content: Text('Error al guardar: $e')),
              );
            }
            created = false;
          }
        },
      ),
    );
    if (created && mounted) {
      await _loadConsultas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConsultas,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar por motivo, estado o historia clinica',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _handleSearch,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadConsultas,
                    child: ListView.builder(
                      itemCount: _filteredConsultas.length,
                      itemBuilder: (context, index) {
                        final consulta = _filteredConsultas[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            title: Text(consulta.motivoConsulta),
                            subtitle: Text(
                              'Historia: ${consulta.historiaClinicaId}\nEstado: ${consulta.estadoConsulta}',
                            ),
                            trailing: Text('#${consulta.idConsulta}'),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleCreateConsulta,
        child: const Icon(Icons.add),
      ),
    );
  }
}
