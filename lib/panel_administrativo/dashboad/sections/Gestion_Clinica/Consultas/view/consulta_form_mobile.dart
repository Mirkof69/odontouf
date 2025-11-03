import 'package:flutter/material.dart';
import '../model/consulta_model.dart';
import '../../Historias_clinicas/controller/historias_clinicas_controller.dart';
import '../../../Central/Usuarios/controller/usuario_controller.dart';
import '../../Historias_clinicas/model/historia_clinica_model.dart';
import '../../../Central/Usuarios/model/usuario_model.dart';
import '../../../Central/Pacientes/controller/pacientes_controller.dart';
import '../../../Central/Pacientes/model/paciente_model.dart';

class ConsultaFormMobile extends StatefulWidget {
  final void Function(Consulta consulta) onSave;
  const ConsultaFormMobile({super.key, required this.onSave});

  @override
  State<ConsultaFormMobile> createState() => _ConsultaFormMobileState();
}

class _ConsultaFormMobileState extends State<ConsultaFormMobile> {
  List<Paciente> _pacientes = [];
  Paciente? _pacienteSeleccionado;
  final _formKey = GlobalKey<FormState>();
  final _motivoConsultaController = TextEditingController();
  final _historiaEnfermedadActualController = TextEditingController();
  DateTime? _fechaConsulta;
  String _estadoConsulta = 'En Progreso';

  List<HistoriaClinica> _historias = [];
  List<Usuario> _docentes = [];
  List<Usuario> _estudiantes = [];
  HistoriaClinica? _historiaSeleccionada;
  Usuario? _docenteSeleccionado;
  Usuario? _estudianteSeleccionado;
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

    // 1) match by idPaciente
    for (final p in _pacientes) {
      if (norm(p.idPaciente.toString()) == norm(target)) return p;
    }
    // 2) match by CI
    for (final p in _pacientes) {
      if (p.ci.trim() == target) return p;
    }
    // 3) match by numeroHistoriaClinica
    for (final p in _pacientes) {
      if (p.numeroHistoriaClinica.trim() == target) return p;
      if (norm(p.numeroHistoriaClinica) == norm(target)) return p;
    }
    // 4) last try: numeric compare ignoring non-digits
    final digitsT = target.replaceAll(RegExp(r'\D'), '');
    if (digitsT.isNotEmpty) {
      for (final p in _pacientes) {
        final digitsP = p.idPaciente.toString().replaceAll(RegExp(r'\D'), '');
        if (digitsP == digitsT) return p;
      }
    }
    return null;
  }

  // _actualizarPacienteSeleccionado removed: using _findPacienteForHistoria instead

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
                        final pacienteInfo = paciente != null
                            ? '${paciente.nombres} ${paciente.apellidos} (CI: ${paciente.ci})'
                            : 'Paciente no encontrado';
                        return DropdownMenuItem(
                          value: h,
                          child: Text(
                            'ID: ${h.idHistoriaClinica} - $pacienteInfo',
                          ),
                        );
                      }).toList(),
                      onChanged: (h) {
                        setState(() {
                          _historiaSeleccionada = h;
                          debugPrint(
                            'Selected historia.pacienteId: ${h?.pacienteId}',
                          );
                          debugPrint(
                            'Available pacientes ids: ${_pacientes.map((p) => p.idPaciente).toList()}',
                          );
                          _pacienteSeleccionado = _findPacienteForHistoria(h!);
                          debugPrint(
                            'Resolved paciente: ${_pacienteSeleccionado?.idPaciente} - ${_pacienteSeleccionado?.nombres}',
                          );
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Historia Clínica',
                      ),
                      validator: (v) => v == null ? 'Campo requerido' : null,
                    ),
              const SizedBox(height: 8),
              // Mostrar datos del paciente real
              if (_pacienteSeleccionado != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paciente: ${_pacienteSeleccionado!.nombres} ${_pacienteSeleccionado!.apellidos}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('CI: ${_pacienteSeleccionado!.ci}'),
                  ],
                )
              else if (_historiaSeleccionada != null)
                const Text(
                  'Paciente no encontrado',
                  style: TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 8),
              _loading
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<Usuario>(
                      initialValue: _estudianteSeleccionado,
                      isExpanded: true,
                      items: _estudiantes
                          .map(
                            (e) => DropdownMenuItem(
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
                            (d) => DropdownMenuItem(
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
                      : _fechaConsulta!.toString(),
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
