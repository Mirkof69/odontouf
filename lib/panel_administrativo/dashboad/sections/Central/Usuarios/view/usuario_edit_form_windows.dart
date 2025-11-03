import 'package:flutter/material.dart';
import '../model/usuario_model.dart';

class UsuarioEditFormWindows extends StatefulWidget {
  final Usuario usuario;
  final void Function(Usuario usuario) onSave;
  const UsuarioEditFormWindows({
    super.key,
    required this.usuario,
    required this.onSave,
  });

  @override
  State<UsuarioEditFormWindows> createState() => _UsuarioEditFormWindowsState();
}

class _UsuarioEditFormWindowsState extends State<UsuarioEditFormWindows> {
  late TextEditingController _nombreCompletoController;
  late TextEditingController _ciController;
  late TextEditingController _emailController;
  late TextEditingController _nombreUsuarioController;
  late TextEditingController _contrasenaController;
  late TextEditingController _rolController;
  late TextEditingController _semestreController;
  late TextEditingController _especialidadDocenteController;
  String _estado = 'Activo';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nombreCompletoController = TextEditingController(
      text: widget.usuario.nombreCompleto,
    );
    _ciController = TextEditingController(text: widget.usuario.ci);
    _emailController = TextEditingController(text: widget.usuario.email);
    _nombreUsuarioController = TextEditingController(
      text: widget.usuario.nombreUsuario,
    );
    _contrasenaController = TextEditingController(
      text: widget.usuario.contrasenaHash,
    );
    _rolController = TextEditingController(text: widget.usuario.rol);
    _semestreController = TextEditingController(
      text: widget.usuario.semestre?.toString() ?? '',
    );
    _especialidadDocenteController = TextEditingController(
      text: widget.usuario.especialidadDocente ?? '',
    );
    _estado = widget.usuario.estado;
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF23272A),
      title: const Text(
        'Editar Usuario',
        style: TextStyle(color: Color(0xFF00E6FB)),
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
                TextFormField(
                  controller: _semestreController,
                  decoration: const InputDecoration(labelText: 'Semestre'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      _rolController.text == 'Estudiante' &&
                          (v == null || v.isEmpty)
                      ? 'Campo requerido'
                      : null,
                ),
              if (_rolController.text == 'Docente')
                TextFormField(
                  controller: _especialidadDocenteController,
                  decoration: const InputDecoration(
                    labelText: 'Especialidad docente',
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
          child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00E6FB),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final usuario = Usuario(
                idUsuario: widget.usuario.idUsuario,
                nombreCompleto: _nombreCompletoController.text,
                ci: _ciController.text,
                email: _emailController.text,
                nombreUsuario: _nombreUsuarioController.text,
                contrasenaHash: _contrasenaController.text,
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
