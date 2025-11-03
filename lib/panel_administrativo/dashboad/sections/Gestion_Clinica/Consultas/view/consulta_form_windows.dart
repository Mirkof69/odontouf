import 'package:flutter/material.dart';
import '../model/consulta_model.dart';
import '../../Historias_clinicas/controller/historias_clinicas_controller.dart';
import '../../../Central/Usuarios/controller/usuario_controller.dart';
import '../../Historias_clinicas/model/historia_clinica_model.dart';
import '../../../Central/Usuarios/model/usuario_model.dart';
import '../../../Central/Pacientes/controller/pacientes_controller.dart';
import '../../../Central/Pacientes/model/paciente_model.dart';

class ConsultaFormWindows extends StatefulWidget {
  final void Function(Consulta consulta) onSave;
  const ConsultaFormWindows({super.key, required this.onSave});

  @override
  State<ConsultaFormWindows> createState() => _ConsultaFormWindowsState();
}

class _ConsultaFormWindowsState extends State<ConsultaFormWindows> {
  final _formKey = GlobalKey<FormState>();
  final _motivoConsultaController = TextEditingController();
  final _historiaEnfermedadActualController = TextEditingController();
  DateTime? _fechaConsulta;
  String _estadoConsulta = 'En Progreso';

  List<HistoriaClinica> _historias = [];
  List<Usuario> _docentes = [];
  List<Usuario> _estudiantes = [];
  List<Paciente> _pacientes = [];
  HistoriaClinica? _historiaSeleccionada;
  Usuario? _docenteSeleccionado;
  Usuario? _estudianteSeleccionado;
  Paciente? _pacienteSeleccionado;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final historias = await HistoriasClinicasController()
        .getHistoriasClinicas();
    final usuariosRaw = await fetchUsuariosDesdeRTDB();
    final docentes = usuariosRaw
        .where((u) => (u['rol'] ?? '').toString() == 'Docente')
        .map((u) => Usuario.fromMap(u))
        .toList();
    final estudiantes = usuariosRaw
        .where((u) => (u['rol'] ?? '').toString() == 'Estudiante')
        .map((u) => Usuario.fromMap(u))
        .toList();
    final pacientes = await PacientesController().getPacientes();
    setState(() {
      _historias = historias;
      _docentes = docentes;
      _estudiantes = estudiantes;
      _pacientes = pacientes;
      _loading = false;
    });
  }

  Paciente? _findPacienteForHistoria(HistoriaClinica h) {
    final target = h.pacienteId.toString().trim();
    if (target.isEmpty) return null;
    String norm(String s) => s.trim().replaceAll(RegExp(r'^0+|\s+'), '');

    for (final p in _pacientes) {
      if (norm(p.idPaciente.toString()) == norm(target)) return p;
    }
    for (final p in _pacientes) {
      if (p.ci.trim() == target) return p;
    }
    for (final p in _pacientes) {
      if (p.numeroHistoriaClinica.trim() == target) return p;
      if (norm(p.numeroHistoriaClinica) == norm(target)) return p;
    }
    final digitsT = target.replaceAll(RegExp(r'\D'), '');
    if (digitsT.isNotEmpty) {
      for (final p in _pacientes) {
        final digitsP = p.idPaciente.toString().replaceAll(RegExp(r'\D'), '');
        if (digitsP == digitsT) return p;
      }
    }
    return null;
  }

  String _historiaLabel(HistoriaClinica h, Paciente? paciente) {
    final numero = paciente?.numeroHistoriaClinica.trim() ?? '';
    final numeroTexto = numero.isNotEmpty
        ? numero
        : 'ID ${h.idHistoriaClinica}';
    if (paciente == null) {
      return 'HC: $numeroTexto - Paciente no encontrado';
    }
    return 'HC: $numeroTexto - ${paciente.nombres} ${paciente.apellidos} (CI: ${paciente.ci})';
  }

  @override
  void dispose() {
    _motivoConsultaController.dispose();
    _historiaEnfermedadActualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 7, 199, 157),
      title: const Text(
        'Agregar Consulta',
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
                  : DropdownButtonFormField<HistoriaClinica>(
                      initialValue: _historiaSeleccionada,
                      isExpanded: true,
                      items: _historias.map((h) {
                        final paciente = _findPacienteForHistoria(h);
                        return DropdownMenuItem(
                          value: h,
                          child: Text(_historiaLabel(h, paciente)),
                        );
                      }).toList(),
                      onChanged: (h) {
                        setState(() {
                          _historiaSeleccionada = h;
                          _pacienteSeleccionado = h == null
                              ? null
                              : _findPacienteForHistoria(h);
                          _docenteSeleccionado = null;
                          _estudianteSeleccionado = null;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Historia Clínica',
                      ),
                      validator: (v) => v == null ? 'Campo requerido' : null,
                    ),
              const SizedBox(height: 8),
              if (_pacienteSeleccionado != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(15, 0, 0, 0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Historia Clínica: ${_pacienteSeleccionado!.numeroHistoriaClinica.isNotEmpty ? _pacienteSeleccionado!.numeroHistoriaClinica : _historiaSeleccionada?.idHistoriaClinica.toString() ?? '-'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (_historiaSeleccionada != null)
                        Text(
                          'ID interno: ${_historiaSeleccionada!.idHistoriaClinica}',
                        ),
                      Text(
                        'Paciente: ${_pacienteSeleccionado!.nombres} ${_pacienteSeleccionado!.apellidos}',
                      ),
                      Text('CI: ${_pacienteSeleccionado!.ci}'),
                    ],
                  ),
                )
              else if (_historiaSeleccionada != null)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Paciente no encontrado para esta historia clínica.',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 8),
              _loading
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<Usuario>(
                      initialValue: _estudianteSeleccionado,
                      isExpanded: true,
                      items: _estudiantes
                          .map(
                            (e) => DropdownMenuItem<Usuario>(
                              value: e,
                              child: Text(
                                'ID: ${e.idUsuario} - ${e.nombreCompleto} (CI: ${e.ci})',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (e) {
                        setState(() {
                          _estudianteSeleccionado = e;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Estudiante Responsable',
                      ),
                      validator: (v) => v == null ? 'Campo requerido' : null,
                    ),
              const SizedBox(height: 8),
              _loading
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<Usuario>(
                      initialValue: _docenteSeleccionado,
                      isExpanded: true,
                      items: _docentes
                          .map(
                            (d) => DropdownMenuItem<Usuario>(
                              value: d,
                              child: Text(
                                'ID: ${d.idUsuario} - ${d.nombreCompleto}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (d) {
                        setState(() {
                          _docenteSeleccionado = d;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Docente Validador',
                      ),
                      validator: (v) => v == null ? 'Campo requerido' : null,
                    ),
              TextFormField(
                controller: _motivoConsultaController,
                decoration: const InputDecoration(labelText: 'Motivo Consulta'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _historiaEnfermedadActualController,
                decoration: const InputDecoration(
                  labelText: 'Historia Enfermedad Actual',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              ListTile(
                title: Text(
                  _fechaConsulta == null
                      ? 'Seleccionar Fecha Consulta'
                      : _fechaConsulta!.toIso8601String(),
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
                    setState(() => _fechaConsulta = picked);
                  }
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: _estadoConsulta,
                items: const [
                  DropdownMenuItem(
                    value: 'En Progreso',
                    child: Text('En Progreso'),
                  ),
                  DropdownMenuItem(
                    value: 'Pendiente Validación',
                    child: Text('Pendiente Validación'),
                  ),
                  DropdownMenuItem(value: 'Aprobada', child: Text('Aprobada')),
                ],
                onChanged: (v) =>
                    setState(() => _estadoConsulta = v ?? 'En Progreso'),
                decoration: const InputDecoration(labelText: 'Estado Consulta'),
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
            if (_formKey.currentState!.validate() && _fechaConsulta != null) {
              final consulta = Consulta(
                idConsulta: 0, // Se debe asignar el ID real al guardar
                historiaClinicaId:
                    _historiaSeleccionada?.idHistoriaClinica.toString() ?? '',
                estudianteId:
                    _estudianteSeleccionado?.idUsuario.toString() ?? '',
                docenteValidadorId:
                    _docenteSeleccionado?.idUsuario.toString() ?? '',
                fechaConsulta: _fechaConsulta!,
                motivoConsulta: _motivoConsultaController.text,
                historiaEnfermedadActual:
                    _historiaEnfermedadActualController.text,
                estadoConsulta: _estadoConsulta,
              );
              widget.onSave(consulta);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
