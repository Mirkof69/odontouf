import 'package:flutter/material.dart';
import '../model/paciente_model.dart';
import '../controller/pacientes_controller.dart';

class PacienteFormMobile extends StatefulWidget {
  final Paciente? paciente;
  final void Function(Paciente paciente) onSave;
  const PacienteFormMobile({super.key, this.paciente, required this.onSave});

  @override
  State<PacienteFormMobile> createState() => _PacienteFormMobileState();
}

class _PacienteFormMobileState extends State<PacienteFormMobile> {
  final _formKey = GlobalKey<FormState>();
  late PacientesController _controller;
  late TextEditingController _nombres;
  late TextEditingController _apellidos;
  late TextEditingController _ci;
  late TextEditingController _numeroHistoriaClinica;
  late TextEditingController _fechaNacimiento;
  String? _sexo;
  String? _estadoCivil;
  String? _ocupacion;
  late TextEditingController _direccion;
  late TextEditingController _celular;
  late TextEditingController _telefono;
  late TextEditingController _contactoEmergenciaNombre;
  late TextEditingController _contactoEmergenciaTelefono;
  bool _loadingHistoria = false;

  final List<String> _sexos = ['Masculino', 'Femenino', 'Otro'];
  final List<String> _estadosCiviles = [
    'Soltero/a',
    'Casado/a',
    'Viudo/a',
    'Divorciado/a',
    'Unión Libre',
  ];
  final List<String> _ocupaciones = [
    'Estudiante',
    'Empleado',
    'Independiente',
    'Desempleado',
    'Jubilado',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    _controller = PacientesController();
    final p = widget.paciente;
    _nombres = TextEditingController(text: p?.nombres ?? '');
    _apellidos = TextEditingController(text: p?.apellidos ?? '');
    _ci = TextEditingController(text: p?.ci ?? '');
    _numeroHistoriaClinica = TextEditingController(
      text: p?.numeroHistoriaClinica ?? '',
    );
    _fechaNacimiento = TextEditingController(
      text: p?.fechaNacimiento.toIso8601String().split('T').first ?? '',
    );
    _sexo = p?.sexo;
    _estadoCivil = p?.estadoCivil;
    _ocupacion = p?.ocupacion;
    _direccion = TextEditingController(text: p?.direccion ?? '');
    _celular = TextEditingController(text: p?.celular ?? '');
    _telefono = TextEditingController(text: p?.telefono ?? '');
    _contactoEmergenciaNombre = TextEditingController(
      text: p?.contactoEmergenciaNombre ?? '',
    );
    _contactoEmergenciaTelefono = TextEditingController(
      text: p?.contactoEmergenciaTelefono ?? '',
    );
    if (widget.paciente == null) _autocompletarHistoria();
  }

  Future<void> _autocompletarHistoria() async {
    setState(() => _loadingHistoria = true);
    final next = await _controller.getNextNumeroHistoriaClinica();
    _numeroHistoriaClinica.text = next;
    setState(() => _loadingHistoria = false);
  }

  @override
  void dispose() {
    _nombres.dispose();
    _apellidos.dispose();
    _ci.dispose();
    _numeroHistoriaClinica.dispose();
    _fechaNacimiento.dispose();
    _direccion.dispose();
    _celular.dispose();
    _telefono.dispose();
    _contactoEmergenciaNombre.dispose();
    _contactoEmergenciaTelefono.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final paciente = Paciente(
        idPaciente:
            widget.paciente?.idPaciente ??
            DateTime.now().millisecondsSinceEpoch,
        numeroHistoriaClinica: _numeroHistoriaClinica.text,
        nombres: _nombres.text,
        apellidos: _apellidos.text,
        ci: _ci.text,
        fechaNacimiento:
            DateTime.tryParse(_fechaNacimiento.text) ?? DateTime(2000),
        sexo: _sexo ?? '',
        estadoCivil: _estadoCivil ?? '',
        ocupacion: _ocupacion ?? '',
        direccion: _direccion.text,
        celular: _celular.text,
        telefono: _telefono.text,
        contactoEmergenciaNombre: _contactoEmergenciaNombre.text,
        contactoEmergenciaTelefono: _contactoEmergenciaTelefono.text,
        fechaRegistro: widget.paciente?.fechaRegistro ?? DateTime.now(),
        activo: widget.paciente?.activo ?? true,
      );
      widget.onSave(paciente);
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickFechaNacimiento() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento.text.isNotEmpty
          ? DateTime.tryParse(_fechaNacimiento.text) ?? DateTime(2000)
          : DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _fechaNacimiento.text = picked.toIso8601String().split('T').first;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.paciente == null ? 'Nuevo Paciente' : 'Editar Paciente',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _numeroHistoriaClinica,
                decoration: const InputDecoration(
                  labelText: 'Historia Clínica',
                ),
                enabled: false,
                readOnly: true,
                validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
              ),
              if (_loadingHistoria) const LinearProgressIndicator(),
              TextFormField(
                controller: _nombres,
                decoration: const InputDecoration(labelText: 'Nombres'),
                validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
              ),
              TextFormField(
                controller: _apellidos,
                decoration: const InputDecoration(labelText: 'Apellidos'),
                validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
              ),
              TextFormField(
                controller: _ci,
                decoration: const InputDecoration(labelText: 'CI'),
                validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
              ),
              GestureDetector(
                onTap: _pickFechaNacimiento,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _fechaNacimiento,
                    decoration: const InputDecoration(
                      labelText: 'Fecha de Nacimiento',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Obligatorio' : null,
                  ),
                ),
              ),
              DropdownButtonFormField<String>(
                initialValue: _sexo,
                decoration: const InputDecoration(labelText: 'Sexo'),
                items: _sexos
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _sexo = v),
                validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
              ),
              DropdownButtonFormField<String>(
                initialValue: _estadoCivil,
                decoration: const InputDecoration(labelText: 'Estado Civil'),
                items: _estadosCiviles
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _estadoCivil = v),
                validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
              ),
              DropdownButtonFormField<String>(
                initialValue: _ocupacion,
                decoration: const InputDecoration(labelText: 'Ocupación'),
                items: _ocupaciones
                    .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                    .toList(),
                onChanged: (v) => setState(() => _ocupacion = v),
                validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
              ),
              TextFormField(
                controller: _direccion,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
              TextFormField(
                controller: _celular,
                decoration: const InputDecoration(labelText: 'Celular'),
              ),
              TextFormField(
                controller: _telefono,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
              TextFormField(
                controller: _contactoEmergenciaNombre,
                decoration: const InputDecoration(
                  labelText: 'Contacto Emergencia (Nombre)',
                ),
              ),
              TextFormField(
                controller: _contactoEmergenciaTelefono,
                decoration: const InputDecoration(
                  labelText: 'Contacto Emergencia (Teléfono)',
                ),
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
        ElevatedButton(onPressed: _submit, child: const Text('Guardar')),
      ],
    );
  }
}
