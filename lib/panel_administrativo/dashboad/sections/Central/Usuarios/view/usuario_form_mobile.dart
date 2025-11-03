import 'package:flutter/material.dart';
import '../model/usuario_model.dart';

class UsuarioFormMobile extends StatefulWidget {
  final void Function(Usuario usuario) onSave;
  const UsuarioFormMobile({super.key, required this.onSave});

  @override
  State<UsuarioFormMobile> createState() => _UsuarioFormMobileState();
}

class _UsuarioFormMobileState extends State<UsuarioFormMobile> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCompletoController;
  late TextEditingController _ciController;
  late TextEditingController _emailController;
  late TextEditingController _nombreUsuarioController;
  late TextEditingController _contrasenaController;
  late TextEditingController _rolController;
  late TextEditingController _semestreController;
  late TextEditingController _especialidadDocenteController;
  @override
  void initState() {
    super.initState();
    _nombreCompletoController = TextEditingController();
    _ciController = TextEditingController();
    _emailController = TextEditingController();
    _nombreUsuarioController = TextEditingController();
    _contrasenaController = TextEditingController();
    _rolController = TextEditingController();
    _semestreController = TextEditingController();
    _especialidadDocenteController = TextEditingController();
  }

  @override
  void dispose() {
    _nombreCompletoController.dispose();
    _ciController.dispose();
    _emailController.dispose();
    _nombreUsuarioController.dispose();
    _contrasenaController.dispose();
    _rolController.dispose();
    _semestreController.dispose();
    _especialidadDocenteController.dispose();
    super.dispose();
  }

  String _estado = 'Activo';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 7, 199, 157),
      title: const Text(
        'Agregar Usuario',
        style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreCompletoController,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _ciController,
                decoration: const InputDecoration(labelText: 'CI'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _nombreUsuarioController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de usuario',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _contrasenaController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              DropdownButtonFormField<String>(
                initialValue: _rolController.text.isNotEmpty
                    ? _rolController.text
                    : null,
                decoration: const InputDecoration(labelText: 'Rol'),
                items: const [
                  DropdownMenuItem(
                    value: 'Administrativo',
                    child: Text('Administrativo'),
                  ),
                  DropdownMenuItem(value: 'Docente', child: Text('Docente')),
                  DropdownMenuItem(
                    value: 'Estudiante',
                    child: Text('Estudiante'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _rolController.text = value ?? '';
                  });
                },
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              if (_rolController.text == 'Estudiante')
                DropdownButtonFormField<String>(
                  initialValue: _semestreController.text.isNotEmpty
                      ? _semestreController.text
                      : null,
                  decoration: const InputDecoration(labelText: 'Semestre'),
                  items: List.generate(
                    10,
                    (i) => DropdownMenuItem(
                      value: (i + 1).toString(),
                      child: Text('${i + 1}'),
                    ),
                  ),
                  onChanged: (v) =>
                      setState(() => _semestreController.text = v ?? ''),
                  validator: (v) =>
                      _rolController.text == 'Estudiante' &&
                          (v == null || v.isEmpty)
                      ? 'Campo requerido'
                      : null,
                ),
              if (_rolController.text == 'Docente')
                DropdownButtonFormField<String>(
                  initialValue: _especialidadDocenteController.text.isNotEmpty
                      ? _especialidadDocenteController.text
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Especialidad docente',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Odontología General',
                      child: Text('Odontología General'),
                    ),
                    DropdownMenuItem(
                      value: 'Ortodoncia',
                      child: Text('Ortodoncia'),
                    ),
                    DropdownMenuItem(
                      value: 'Endodoncia',
                      child: Text('Endodoncia'),
                    ),
                    DropdownMenuItem(
                      value: 'Odontopediatría',
                      child: Text('Odontopediatría'),
                    ),
                    DropdownMenuItem(
                      value: 'Periodoncia',
                      child: Text('Periodoncia'),
                    ),
                    DropdownMenuItem(
                      value: 'Cirugía oral',
                      child: Text('Cirugía oral'),
                    ),
                    DropdownMenuItem(
                      value: 'Prostodoncia',
                      child: Text('Prostodoncia'),
                    ),
                  ],
                  onChanged: (v) => setState(
                    () => _especialidadDocenteController.text = v ?? '',
                  ),
                  validator: (v) =>
                      _rolController.text == 'Docente' &&
                          (v == null || v.isEmpty)
                      ? 'Campo requerido'
                      : null,
                ),
              DropdownButtonFormField<String>(
                initialValue: _estado,
                decoration: const InputDecoration(labelText: 'Estado'),
                items: const [
                  DropdownMenuItem(value: 'Activo', child: Text('Activo')),
                  DropdownMenuItem(value: 'Inactivo', child: Text('Inactivo')),
                ],
                onChanged: (value) {
                  setState(() {
                    _estado = value ?? 'Activo';
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00E6FB),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final usuario = Usuario(
                idUsuario: DateTime.now().millisecondsSinceEpoch,
                nombreCompleto: _nombreCompletoController.text,
                ci: _ciController.text,
                email: _emailController.text,
                nombreUsuario: _nombreUsuarioController.text,
                contrasenaHash:
                    _contrasenaController.text, // Aquí deberías encriptar
                rol: _rolController.text,
                semestre: _rolController.text == 'Estudiante'
                    ? int.tryParse(_semestreController.text)
                    : null,
                especialidadDocente: _rolController.text == 'Docente'
                    ? _especialidadDocenteController.text
                    : null,
                estado: _estado,
              );
              widget.onSave(usuario);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Guardar', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
