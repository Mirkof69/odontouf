import 'package:flutter/material.dart';
import '../model/historia_clinica_model.dart';
import '../../../Central/Pacientes/controller/pacientes_controller.dart';
import '../../../Central/Pacientes/model/paciente_model.dart';

class HistoriaClinicaFormMobile extends StatefulWidget {
  final void Function(HistoriaClinica historia) onSave;
  const HistoriaClinicaFormMobile({super.key, required this.onSave});

  @override
  State<HistoriaClinicaFormMobile> createState() =>
      _HistoriaClinicaFormMobileState();
}

class _HistoriaClinicaFormMobileState extends State<HistoriaClinicaFormMobile> {
  final _formKey = GlobalKey<FormState>();
  List<Paciente> _pacientes = [];
  Paciente? _pacienteSeleccionado;
  bool _loading = true;
  String _search = '';
  DateTime? _fechaApertura;
  String _estadoHistoria = 'Activa';

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _cargarPacientes();
  }

  Future<void> _cargarPacientes() async {
    final pacientes = await PacientesController().getPacientes();
    setState(() {
      _pacientes = pacientes;
      _loading = false;
    });
  }

  List<Paciente> get _pacientesFiltrados {
    if (_search.isEmpty) return _pacientes;
    final q = _search.toLowerCase();
    return _pacientes
        .where(
          (u) =>
              u.nombres.toLowerCase().contains(q) ||
              u.apellidos.toLowerCase().contains(q) ||
              u.ci.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 7, 199, 157),
      title: const Text(
        'Agregar Historia Clínica',
        style: TextStyle(color: Colors.black),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _loading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Buscar paciente por nombre o CI',
                          ),
                          onChanged: (v) => setState(() => _search = v),
                        ),
                        DropdownButtonFormField<Paciente>(
                          isExpanded: true,
                          initialValue: _pacienteSeleccionado,
                          items: _pacientesFiltrados
                              .map(
                                (u) => DropdownMenuItem(
                                  value: u,
                                  child: Text(
                                    'CI: ${u.ci} - ${u.nombres} ${u.apellidos}',
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (u) =>
                              setState(() => _pacienteSeleccionado = u),
                          decoration: const InputDecoration(
                            labelText: 'Seleccionar Paciente',
                          ),
                          validator: (v) =>
                              v == null ? 'Campo requerido' : null,
                        ),
                      ],
                    ),
              ListTile(
                title: Text(
                  _fechaApertura == null
                      ? 'Seleccionar Fecha Apertura'
                      : _fechaApertura!.toString(),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _fechaApertura = picked);
                  }
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: _estadoHistoria,
                items: const [
                  DropdownMenuItem(value: 'Activa', child: Text('Activa')),
                  DropdownMenuItem(
                    value: 'Archivada',
                    child: Text('Archivada'),
                  ),
                  DropdownMenuItem(value: 'De Alta', child: Text('De Alta')),
                ],
                onChanged: (v) =>
                    setState(() => _estadoHistoria = v ?? 'Activa'),
                decoration: const InputDecoration(labelText: 'Estado Historia'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate() && _fechaApertura != null) {
              final historia = HistoriaClinica(
                idHistoriaClinica: 0, // Se debe asignar el ID real al guardar
                pacienteId: _pacienteSeleccionado?.idPaciente.toString() ?? '',
                fechaApertura: _fechaApertura!,
                estadoHistoria: _estadoHistoria,
              );
              widget.onSave(historia);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
