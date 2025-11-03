import 'package:flutter/material.dart';
import '../controller/pacientes_controller.dart';
import '../model/paciente_model.dart';
import 'paciente_form_mobile.dart';

class PacientesViewMobile extends StatefulWidget {
  const PacientesViewMobile({super.key});

  @override
  State<PacientesViewMobile> createState() => _PacientesViewMobileState();
}

class _PacientesViewMobileState extends State<PacientesViewMobile> {
  late PacientesController _controller;
  List<Paciente> _pacientes = [];
  List<Paciente> _filtered = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _controller = PacientesController();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final pacientes = await _controller.getPacientes(incluirInactivos: true);
    setState(() {
      _pacientes = pacientes;
      _filtered = _filterList(_search);
      _loading = false;
    });
    if (mounted && pacientes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay pacientes registrados.')),
      );
    }
  }

  List<Paciente> _filterList(String query) {
    if (query.isEmpty) return _pacientes;
    final q = query.toLowerCase();
    return _pacientes
        .where(
          (p) =>
              p.nombres.toLowerCase().contains(q) ||
              p.apellidos.toLowerCase().contains(q) ||
              p.ci.toLowerCase().contains(q) ||
              p.numeroHistoriaClinica.toLowerCase().contains(q),
        )
        .toList();
  }

  void _onSearch(String value) {
    setState(() {
      _search = value;
      _filtered = _filterList(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacientes'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre, CI o historia clínica',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _onSearch,
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                ? const Center(child: Text('No hay pacientes'))
                : ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (context, i) {
                      final p = _filtered[i];
                      return Card(
                        color: p.activo ? Colors.white : Colors.grey[300],
                        child: ListTile(
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${p.nombres} ${p.apellidos}',
                                  style: TextStyle(
                                    color: p.activo
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                fit: FlexFit.loose,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: p.activo
                                        ? Colors.green[600]
                                        : Colors.red[600],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    p.activo ? 'Activo' : 'Inactivo',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            'CI: ${p.ci}\nHistoria: ${p.numeroHistoriaClinica}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'editar') {
                                showDialog(
                                  context: context,
                                  builder: (context) => PacienteFormMobile(
                                    paciente: p,
                                    onSave: (pacienteEditado) async {
                                      await _controller.editarPaciente(
                                        pacienteEditado,
                                      );
                                      _load();
                                    },
                                  ),
                                );
                              } else if (value == 'eliminar') {
                                await _controller.eliminarLogicoPaciente(
                                  p.idPaciente,
                                );
                                _load();
                              } else if (value == 'reactivar') {
                                await _controller.reactivarPaciente(
                                  p.idPaciente,
                                );
                                _load();
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'editar',
                                child: Text('Editar'),
                              ),
                              if (p.activo)
                                const PopupMenuItem(
                                  value: 'eliminar',
                                  child: Text('Eliminar'),
                                )
                              else
                                const PopupMenuItem(
                                  value: 'reactivar',
                                  child: Text('Reactivar'),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => PacienteFormMobile(
              onSave: (nuevoPaciente) async {
                await _controller.agregarPaciente(nuevoPaciente);
                _load();
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
