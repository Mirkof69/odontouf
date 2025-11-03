import 'package:flutter/material.dart';
import '../controller/historias_clinicas_controller.dart';
import '../model/historia_clinica_model.dart';
import 'historia_clinica_form_mobile.dart';

class HistoriasClinicasViewMobile extends StatefulWidget {
  const HistoriasClinicasViewMobile({super.key});

  @override
  State<HistoriasClinicasViewMobile> createState() =>
      _HistoriasClinicasViewMobileState();
}

class _HistoriasClinicasViewMobileState
    extends State<HistoriasClinicasViewMobile> {
  final HistoriasClinicasController _controller = HistoriasClinicasController();
  List<HistoriaClinica> _historias = [];
  List<HistoriaClinica> _filteredHistorias = [];
  bool _isLoading = true;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _loadHistorias();
  }

  Future<void> _loadHistorias() async {
    setState(() => _isLoading = true);
    final historias = await _controller.getHistoriasClinicas();
    if (!mounted) return;
    setState(() {
      _historias = historias;
      _filteredHistorias = _applyFilter(_searchTerm);
      _isLoading = false;
    });
    if (historias.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay historias registradas.')),
      );
    }
  }

  List<HistoriaClinica> _applyFilter(String query) {
    if (query.isEmpty) return List<HistoriaClinica>.from(_historias);
    final lowerQuery = query.toLowerCase();
    return _historias
        .where(
          (historia) =>
              historia.pacienteId.toString().toLowerCase().contains(
                lowerQuery,
              ) ||
              historia.estadoHistoria.toLowerCase().contains(lowerQuery) ||
              historia.idHistoriaClinica.toString().contains(lowerQuery),
        )
        .toList();
  }

  void _handleSearch(String value) {
    setState(() {
      _searchTerm = value;
      _filteredHistorias = _applyFilter(value);
    });
  }

  Future<void> _handleCreateHistoria() async {
    var created = false;
    await showDialog<void>(
      context: context,
      builder: (context) => HistoriaClinicaFormMobile(
        onSave: (historia) async {
          final nextId = await _controller.getNextIdHistoriaClinica();
          final nuevaHistoria = HistoriaClinica(
            idHistoriaClinica: int.tryParse(nextId) ?? 0,
            pacienteId: historia.pacienteId,
            fechaApertura: historia.fechaApertura,
            estadoHistoria: historia.estadoHistoria,
          );
          await _controller.agregarHistoriaClinica(nuevaHistoria);
          created = true;
        },
      ),
    );
    if (created && mounted) {
      await _loadHistorias();
    }
  }

  String _formatDate(DateTime date) {
    final dateString = date.toIso8601String();
    return dateString.split('T').first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historias Clinicas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistorias,
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
                hintText: 'Buscar por paciente, estado o ID',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _handleSearch,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadHistorias,
                    child: ListView.builder(
                      itemCount: _filteredHistorias.length,
                      itemBuilder: (context, index) {
                        final historia = _filteredHistorias[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            title: Text('Paciente: ${historia.pacienteId}'),
                            subtitle: Text(
                              'Fecha: ${_formatDate(historia.fechaApertura)}\nEstado: ${historia.estadoHistoria}',
                            ),
                            trailing: Text('#${historia.idHistoriaClinica}'),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleCreateHistoria,
        child: const Icon(Icons.add),
      ),
    );
  }
}
