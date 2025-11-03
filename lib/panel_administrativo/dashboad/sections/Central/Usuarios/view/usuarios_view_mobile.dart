import 'package:flutter/material.dart';
import '../controller/usuario_controller.dart';
import 'usuario_form_mobile.dart';

class UsuariosViewMobile extends StatefulWidget {
  const UsuariosViewMobile({super.key});

  @override
  State<UsuariosViewMobile> createState() => _UsuariosViewMobileState();
}

class _UsuariosViewMobileState extends State<UsuariosViewMobile> {
  late final UsuarioController _controller;
  // local UI state
  String _search = '';
  String _selectedRol = 'Todos';
  String _selectedEstado = 'Todos';
  late final VoidCallback _controllerListener;

  @override
  void initState() {
    super.initState();
    _controller = UsuarioController();
    // listen to controller changes and refresh UI
    _controllerListener = () {
      if (mounted) setState(() {});
    };
    _controller.addListener(_controllerListener);
    // load once when this widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.cargarUsuarios();
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_controllerListener);
    _controller.dispose();
    super.dispose();
  }

  List<String> get _roles {
    final roles = <String>{'Todos'};
    for (final u in _controller.usuarios) {
      roles.add(u.rol);
    }
    return roles.toList();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final usuariosFiltrados = controller.usuarios.where((u) {
      final matchesSearch =
          _search.isEmpty ||
          u.nombreCompleto.toLowerCase().contains(_search.toLowerCase()) ||
          u.ci.toLowerCase().contains(_search.toLowerCase()) ||
          u.email.toLowerCase().contains(_search.toLowerCase()) ||
          u.nombreUsuario.toLowerCase().contains(_search.toLowerCase());
      final matchesRol = _selectedRol == 'Todos' || u.rol == _selectedRol;
      final matchesEstado =
          _selectedEstado == 'Todos' ||
          (_selectedEstado == 'Activo' && u.estado == 'Activo') ||
          (_selectedEstado == 'Inactivo' && u.estado == 'Inactivo');
      return matchesSearch && matchesRol && matchesEstado;
    }).toList();
    return Scaffold(
      backgroundColor: const Color(0xFF181A1B),
      appBar: AppBar(
        title: const Text(
          'Usuarios',
          style: TextStyle(color: Color(0xFF00E6FB)),
        ),
        backgroundColor: const Color(0xFF23272A),
        iconTheme: const IconThemeData(color: Color(0xFF00E6FB)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 200),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre, CI, email o usuario',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: const Color(0xFF23272A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF00E6FB),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => _search = value);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 110),
                    child: SizedBox(
                      width: 120,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedRol,
                        decoration: const InputDecoration(
                          labelText: 'Rol',
                          filled: true,
                          fillColor: Color(0xFF23272A),
                        ),
                        dropdownColor: const Color(0xFF23272A),
                        items: _roles
                            .map(
                              (rol) => DropdownMenuItem(
                                value: rol,
                                child: Text(
                                  rol,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedRol = value ?? 'Todos');
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 110),
                    child: SizedBox(
                      width: 120,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedEstado,
                        decoration: const InputDecoration(
                          labelText: 'Estado',
                          filled: true,
                          fillColor: Color(0xFF23272A),
                        ),
                        dropdownColor: const Color(0xFF23272A),
                        items: const [
                          DropdownMenuItem(
                            value: 'Todos',
                            child: Text(
                              'Todos',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Activo',
                            child: Text(
                              'Activo',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Inactivo',
                            child: Text(
                              'Inactivo',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedEstado = value ?? 'Todos');
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: usuariosFiltrados.isEmpty
                ? const Center(
                    child: Text(
                      'No hay usuarios registrados',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    itemCount: usuariosFiltrados.length,
                    itemBuilder: (context, index) {
                      final usuario = usuariosFiltrados[index];
                      return Card(
                        color: usuario.estado == 'Inactivo'
                            ? Colors.grey[800]
                            : const Color(0xFF23272A),
                        child: ListTile(
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  usuario.nombreCompleto,
                                  style: TextStyle(
                                    color: usuario.estado == 'Inactivo'
                                        ? Colors.grey
                                        : Colors.white,
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
                                    color: usuario.estado == 'Activo'
                                        ? Colors.green[600]
                                        : Colors.red[600],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    usuario.estado == 'Activo'
                                        ? 'Activo'
                                        : 'Inactivo',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                usuario.email,
                                style: const TextStyle(
                                  color: Color(0xFF00E6FB),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rol: ${usuario.rol}',
                                style: const TextStyle(color: Colors.white70),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          trailing: SizedBox(
                            width: 48,
                            child: Center(
                              child: usuario.estado == 'Activo'
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      tooltip: 'Eliminar (lógico)',
                                      onPressed: () async {
                                        await controller.eliminarUsuario(
                                          usuario.idUsuario,
                                        );
                                      },
                                    )
                                  : const Icon(Icons.block, color: Colors.grey),
                            ),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00E6FB),
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => UsuarioFormMobile(
              onSave: (usuario) async {
                await controller.agregarUsuario(usuario);
              },
            ),
          );
        },
      ),
    );
  }
}
