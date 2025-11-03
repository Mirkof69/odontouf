import 'package:flutter/material.dart';
import '../controller/usuario_controller.dart';
import '../controller/usuario_controller_windows.dart';
import '../controller/iusuario_controller.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'usuario_form_windows.dart';

class UsuariosViewWindows extends StatefulWidget {
  const UsuariosViewWindows({super.key});

  @override
  State<UsuariosViewWindows> createState() => _UsuariosViewWindowsState();
}

class _UsuariosViewWindowsState extends State<UsuariosViewWindows> {
  late final IUsuarioController _controller;

  @override
  void initState() {
    super.initState();
    _controller = (kIsWeb)
        ? UsuarioController()
        : (Platform.isWindows
              ? UsuarioControllerWindows()
              : UsuarioController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      (_controller as dynamic).cargarUsuarios();
    });
  }

  @override
  void dispose() {
    (_controller as ChangeNotifier).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<IUsuarioController>.value(
      value: _controller,
      builder: (context, _) => const _UsuariosBody(),
    );
  }
}

class _UsuariosBody extends StatefulWidget {
  const _UsuariosBody();
  @override
  State<_UsuariosBody> createState() => _UsuariosBodyState();
}

class _UsuariosBodyState extends State<_UsuariosBody> {
  int? _loadingUserId;
  String _search = '';
  String _selectedRol = 'Todos';
  String _selectedEstado = 'Todos';

  List<String> get _roles {
    final roles = <String>{'Todos'};
    for (final u in Provider.of<IUsuarioController>(
      context,
      listen: false,
    ).usuarios) {
      roles.add(u.rol);
    }
    return roles.toList();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<IUsuarioController>(context);
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 300),
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
                    constraints: const BoxConstraints(minWidth: 140),
                    child: SizedBox(
                      width: 160,
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
                    constraints: const BoxConstraints(minWidth: 140),
                    child: SizedBox(
                      width: 160,
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
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E6FB),
                    ),
                    icon: const Icon(Icons.add, color: Colors.black),
                    label: const Text(
                      'Nuevo Usuario',
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => UsuarioFormWindows(
                          onSave: (usuario) async {
                            await controller.agregarUsuario(usuario);
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
                            subtitle: Text(
                              usuario.email,
                              style: const TextStyle(color: Color(0xFF00E6FB)),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 100,
                                  ),
                                  child: Text(
                                    usuario.rol,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (usuario.estado == 'Activo')
                                  _loadingUserId == usuario.idUsuario
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          tooltip: 'Eliminar (lógico)',
                                          onPressed: () async {
                                            setState(
                                              () => _loadingUserId =
                                                  usuario.idUsuario,
                                            );
                                            await controller.eliminarUsuario(
                                              usuario.idUsuario,
                                            );
                                            setState(
                                              () => _loadingUserId = null,
                                            );
                                          },
                                        ),
                                if (usuario.estado == 'Inactivo')
                                  _loadingUserId == usuario.idUsuario
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : IconButton(
                                          icon: const Icon(
                                            Icons.refresh,
                                            color: Colors.greenAccent,
                                          ),
                                          tooltip: 'Reactivar',
                                          onPressed: () async {
                                            setState(
                                              () => _loadingUserId =
                                                  usuario.idUsuario,
                                            );
                                            await controller.reactivarUsuario(
                                              usuario.idUsuario,
                                            );
                                            setState(
                                              () => _loadingUserId = null,
                                            );
                                          },
                                        ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Color(0xFF00E6FB),
                                  ),
                                  tooltip: 'Editar',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => UsuarioFormWindows(
                                        onSave: (usuarioEditado) async {
                                          await controller.actualizarUsuario(
                                            usuario.idUsuario,
                                            usuarioEditado.copyWith(
                                              idUsuario: usuario.idUsuario,
                                            ),
                                          );
                                        },
                                        usuario: usuario,
                                      ),
                                    );
                                  },
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
      ),
    );
  }
}
