import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/paleta_colores.dart' as pal;
import 'package:flutter_application_1/widgets/barra_nav_superior.dart';
import 'package:flutter_application_1/widgets/barra_nav_inferior.dart';
import 'package:flutter_application_1/services/usuario_service.dart';
import '../Turnos/reservar_turno.dart';

class MiPerfilScreen extends StatefulWidget {
  const MiPerfilScreen({super.key});

  @override
  State<MiPerfilScreen> createState() => _MiPerfilScreenState();
}

class _MiPerfilScreenState extends State<MiPerfilScreen> {
  int _bottomIndex = 0;
  bool _isLoading = true;
  // ignore: unused_field
  int? _usuarioId;

  // ====== DATOS DEL USUARIO ======
  String _nombreCompleto = '';
  String _email = '';
  String _fechaNac = '';
  String _dni = '';
  String _obraSocial = '';
  String _plan = '';
  String _numeroAfiliado = '';
  int? _idObraSocial;

  // ====== Lista de obras sociales ======
  List<Map<String, dynamic>> _obrasSociales = [];
  bool _isLoadingObras = false;

  // ====== Edit mode toggles ======
  bool _editDatos = false;
  bool _editCobertura = false;

  // ====== Controllers ======
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _emailCtrl;        // readOnly
  late final TextEditingController _fechaNacCtrl;     // readOnly + date picker
  late final TextEditingController _dniCtrl;

  late final TextEditingController _obraCtrl;
  late final TextEditingController _planCtrl;
  late final TextEditingController _afiliadoCtrl;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _fechaNacCtrl = TextEditingController();
    _dniCtrl = TextEditingController();

    _obraCtrl = TextEditingController();
    _planCtrl = TextEditingController();
    _afiliadoCtrl = TextEditingController();

    _cargarDatosUsuario();
  }

  /// Cargar datos del usuario desde la base de datos
  Future<void> _cargarDatosUsuario() async {
    setState(() => _isLoading = true);

    try {
      final datos = await UsuarioService.obtenerUsuarioActual();
      
      if (datos == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al cargar los datos del perfil')),
          );
        }
        return;
      }

      // Extraer datos
      _usuarioId = datos['id'];
      _email = datos['email'] ?? '';
      final nombre = datos['nombre'] ?? '';
      final apellido = datos['apellido'] ?? '';
      _nombreCompleto = '$nombre $apellido'.trim();
      _dni = datos['documento'] ?? '';
      
      // Formatear fecha de nacimiento de YYYY-MM-DD a DD/MM/YYYY
      final fechaStr = datos['fecha_nacimiento'] ?? '';
      if (fechaStr.isNotEmpty) {
        try {
          final partes = fechaStr.split('-');
          if (partes.length == 3) {
            _fechaNac = '${partes[2]}/${partes[1]}/${partes[0]}';
          }
        } catch (_) {
          _fechaNac = fechaStr;
        }
      }

      // Datos de obra social
      _idObraSocial = datos['id_obra_social'];
      if (datos['obra_social'] != null) {
        _obraSocial = datos['obra_social']['nombre'] ?? '';
      }
      _plan = datos['plan_obra_social'] ?? '';
      _numeroAfiliado = datos['nro_afiliado'] ?? '';

      // Actualizar controllers
      _nombreCtrl.text = _nombreCompleto;
      _emailCtrl.text = _email;
      _fechaNacCtrl.text = _fechaNac;
      _dniCtrl.text = _dni;
      _obraCtrl.text = _obraSocial;
      _planCtrl.text = _plan;
      _afiliadoCtrl.text = _numeroAfiliado;

      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _fechaNacCtrl.dispose();
    _dniCtrl.dispose();
    _obraCtrl.dispose();
    _planCtrl.dispose();
    _afiliadoCtrl.dispose();
    super.dispose();
  }

  // ====== Acciones ======
  void _toggleEditDatos() => setState(() => _editDatos = !_editDatos);
  
  void _toggleEditCobertura() async {
    if (!_editCobertura && _obrasSociales.isEmpty) {
      // Cargar obras sociales solo cuando se activa el modo edición
      setState(() => _isLoadingObras = true);
      final obras = await UsuarioService.obtenerObrasSociales();
      setState(() {
        _obrasSociales = obras;
        _isLoadingObras = false;
      });
    }
    setState(() => _editCobertura = !_editCobertura);
  }

  void _cancelEditDatos() {
    setState(() {
      _editDatos = false;
      _nombreCtrl.text = _nombreCompleto;
      _fechaNacCtrl.text = _fechaNac;
      _dniCtrl.text = _dni;
    });
  }

  void _cancelEditCobertura() {
    setState(() {
      _editCobertura = false;
      _obraCtrl.text = _obraSocial;
      _planCtrl.text = _plan;
      _afiliadoCtrl.text = _numeroAfiliado;
      // Restaurar el ID original
      if (_idObraSocial != null) {
        final obraOriginal = _obrasSociales.firstWhere(
          (o) => o['id'] == _idObraSocial,
          orElse: () => {},
        );
        if (obraOriginal.isNotEmpty) {
          _obraCtrl.text = obraOriginal['nombre'] ?? _obraSocial;
        }
      }
    });
  }

  Future<void> _saveDatos() async {
    // Separar nombre y apellido
    final nombreCompleto = _nombreCtrl.text.trim();
    final partes = nombreCompleto.split(' ');
    final nombre = partes.isNotEmpty ? partes[0] : '';
    final apellido = partes.length > 1 ? partes.sublist(1).join(' ') : '';

    // Convertir fecha de DD/MM/YYYY a YYYY-MM-DD
    final fechaInput = _fechaNacCtrl.text.trim();
    String fechaISO = fechaInput;
    try {
      final partesFecha = fechaInput.split('/');
      if (partesFecha.length == 3) {
        fechaISO = '${partesFecha[2]}-${partesFecha[1]}-${partesFecha[0]}';
      }
    } catch (_) {}

    final resultado = await UsuarioService.actualizarDatosPersonales(
      nombre: nombre,
      apellido: apellido,
      documento: _dniCtrl.text.trim(),
      fechaNacimiento: fechaISO,
    );

    if (resultado['success'] == true) {
      setState(() {
        _nombreCompleto = nombreCompleto;
        _fechaNac = fechaInput;
        _dni = _dniCtrl.text.trim();
        _editDatos = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos personales guardados exitosamente')),
        );
      }
    } else {
      if (mounted) {
        final mensaje = resultado['message'] ?? 'Error al guardar los datos';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensaje)),
        );
      }
    }
  }

  Future<void> _saveCobertura() async {
    if (_idObraSocial == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se pudo obtener el ID de obra social')),
      );
      return;
    }

    final exitoso = await UsuarioService.actualizarCobertura(
      idObraSocial: _idObraSocial!,
      planObraSocial: _planCtrl.text.trim(),
      nroAfiliado: _afiliadoCtrl.text.trim(),
    );

    if (exitoso) {
      setState(() {
        _obraSocial = _obraCtrl.text.trim();
        _plan = _planCtrl.text.trim();
        _numeroAfiliado = _afiliadoCtrl.text.trim();
        _editCobertura = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cobertura médica guardada exitosamente')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar la cobertura')),
        );
      }
    }
  }

  Future<void> _pickFechaNac() async {
    // Intenta parsear dd/MM/yyyy
    DateTime initial = DateTime.now();
    try {
      final p = _fechaNacCtrl.text.split('/');
      if (p.length == 3) {
        initial = DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
      }
    } catch (_) {}
    final first = DateTime(1900);
    final last = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(last) ? last : initial,
      firstDate: first,
      lastDate: last,
      helpText: 'Seleccionar fecha de nacimiento',
      confirmText: 'Aceptar',
      cancelText: 'Cancelar',
    );
    if (picked != null) {
      final dd = picked.day.toString().padLeft(2, '0');
      final mm = picked.month.toString().padLeft(2, '0');
      final yyyy = picked.year.toString();
      _fechaNacCtrl.text = '$dd/$mm/$yyyy';
      setState(() {});
    }
  }

  Future<void> _confirmarEliminarCuenta() async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _EliminarCuentaDialog(),
    );
    if (ok == true) {
      await _eliminarCuenta();
    }
  }

  Future<void> _eliminarCuenta() async {
    final exitoso = await UsuarioService.eliminarCuenta();

    if (!mounted) return;

    if (exitoso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta eliminada exitosamente')),
      );
      // Redirigir al login
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar la cuenta')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pal.fondo,
      appBar: CustomTopBar.back(title: 'Perfil'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ===== Datos personales =====
                    _PerfilCard(
                      title: 'Datos Personales',
                      onEdit: _toggleEditDatos,
                      children: _editDatos ? _datosPersonalesEdit() : _datosPersonalesView(),
                    ),
                    const SizedBox(height: 12),

                    // ===== Cobertura Médica =====
                    _PerfilCard(
                      title: 'Cobertura Medica',
                      onEdit: _toggleEditCobertura,
                      children: _editCobertura ? _coberturaEdit() : _coberturaView(),
                    ),

                    const SizedBox(height: 16),

                    // Botón eliminar
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE57373),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _confirmarEliminarCuenta,
                      child: const Text('Eliminar cuenta', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),

      bottomNavigationBar: CustomBottomNav(
        currentIndex: _bottomIndex,
        onDestinationSelected: (i) {
          setState(() => _bottomIndex = i);
          if (i == 0) {
            Navigator.of(context).popUntil((r) => r.isFirst);
          } else {
            Navigator.of(context).maybePop();
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: pal.colorAcento,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ReservarTurnoWizard()),
          );
        },
        child: const Icon(Icons.calendar_month),
      ),
    );
  }

  // ===== Vistas / Edits =====
  List<Widget> _datosPersonalesView() => [
        _kv('Nombre', _nombreCompleto),
        const SizedBox(height: 6),
        _kv('Email', _email, isLinky: true),
        const SizedBox(height: 6),
        _kv('Fecha de nacimiento', _fechaNac),
        const SizedBox(height: 6),
        _kv('DNI', _dni),
      ];

  List<Widget> _datosPersonalesEdit() => [
        _underlineField(label: 'Nombre', controller: _nombreCtrl, textInputAction: TextInputAction.next),
        const SizedBox(height: 6),
        _underlineField(
          label: 'Email',
          controller: _emailCtrl,
          readOnly: true,                 // 🔒 SOLO LECTURA
          helperText: 'No es posible editar el correo electrónico',
        ),
        const SizedBox(height: 6),
        _underlineField(
          label: 'Fecha de nacimiento',
          controller: _fechaNacCtrl,
          readOnly: true,
          suffixIcon: IconButton(
            icon: const Icon(Icons.date_range),
            color: pal.colorAcento,
            onPressed: _pickFechaNac,
          ),
        ),
        const SizedBox(height: 6),
        _underlineField(
          label: 'DNI',
          controller: _dniCtrl,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        _editActions(onCancel: _cancelEditDatos, onSave: _saveDatos),
      ];

  List<Widget> _coberturaView() => [
        _kv('Obra Social', _obraSocial),
        const SizedBox(height: 6),
        _kv('Plan', _plan),
        const SizedBox(height: 6),
        _kv('Número Afiliado', _numeroAfiliado),
      ];

  List<Widget> _coberturaEdit() => [
        // Selector de Obra Social
        if (_isLoadingObras)
          const Center(child: CircularProgressIndicator())
        else
          DropdownButtonFormField<int>(
            value: _idObraSocial,
            decoration: InputDecoration(
              labelText: 'Obra Social',
              isDense: true,
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: pal.colorAcento, width: 1.6),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black.withOpacity(.25)),
              ),
            ),
            items: _obrasSociales.map((obra) {
              return DropdownMenuItem<int>(
                value: obra['id'] as int,
                child: Text(obra['nombre'] as String),
              );
            }).toList(),
            onChanged: (nuevoId) {
              setState(() {
                _idObraSocial = nuevoId;
                final obraSeleccionada = _obrasSociales.firstWhere(
                  (o) => o['id'] == nuevoId,
                  orElse: () => {},
                );
                if (obraSeleccionada.isNotEmpty) {
                  _obraCtrl.text = obraSeleccionada['nombre'] ?? '';
                  _obraSocial = obraSeleccionada['nombre'] ?? '';
                }
              });
            },
          ),
        const SizedBox(height: 6),
        _underlineField(label: 'Plan', controller: _planCtrl, textInputAction: TextInputAction.next),
        const SizedBox(height: 6),
        _underlineField(
          label: 'Número Afiliado',
          controller: _afiliadoCtrl,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        _editActions(onCancel: _cancelEditCobertura, onSave: _saveCobertura),
      ];

  // ===== Helpers =====
  Widget _kv(String k, String v, {bool isLinky = false}) {
    final label = k.trim().isEmpty
        ? null
        : Text(
            k,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          );
    final value = isLinky
        ? Text(
            v,
            style: const TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.black,
              fontSize: 15.5,
            ),
          )
        : Text(
            v,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15.5,
              height: 1.2,
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) label,
        if (label != null) const SizedBox(height: 2),
        value,
      ],
    );
  }

  // Campo subrayado estilo Material por defecto (UnderlineInputBorder)
  Widget _underlineField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    Widget? suffixIcon,
    String? helperText,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        isDense: true,
        // color de foco con tu acento
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: pal.colorAcento, width: 1.6),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black.withOpacity(.25)),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  // Botonera de edición (Cancelar / Guardar)
  Widget _editActions({required VoidCallback onCancel, required VoidCallback onSave}) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: ButtonStyle(
              minimumSize: WidgetStateProperty.all(const Size.fromHeight(44)),
              side: WidgetStateProperty.all(
                BorderSide(color: pal.colorAtencion, width: 1.6),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              ),
              overlayColor: WidgetStateProperty.all(
                pal.colorAtencion.withOpacity(0.15),
              ),
            ),
            onPressed: onCancel,
            child: Text(
              'Cancelar',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: pal.colorAtencion,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            style: ButtonStyle(
              minimumSize: WidgetStateProperty.all(const Size.fromHeight(44)),
              backgroundColor: WidgetStateProperty.all(pal.colorAcento),
              foregroundColor: WidgetStateProperty.all(Colors.white),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              ),
              overlayColor: WidgetStateProperty.all(
                Colors.white.withOpacity(0.10),
              ),
              elevation: WidgetStateProperty.all(0),
            ),
            onPressed: onSave,
            child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}

// ====== Contenedor CARD ======
class _PerfilCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback? onEdit;

  const _PerfilCard({
    required this.title,
    required this.children,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: pal.colorSecundario,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(.08)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: onEdit,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.edit, color: pal.colorAcento, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

// ====== DIALOGO CONFIRMAR ELIMINAR ======
class _EliminarCuentaDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 34, color: Colors.redAccent),
            const SizedBox(height: 10),
            const Text(
              '¿Estás seguro de que deseas eliminar tu cuenta?',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Esta acción es permanente y no podrás recuperar tus datos ni tus turnos asociados.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: ButtonStyle(
                      minimumSize: WidgetStateProperty.all(const Size.fromHeight(44)),
                      side: WidgetStateProperty.all(
                        BorderSide(color: pal.colorAtencion, width: 1.6),
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                      overlayColor: WidgetStateProperty.all(
                        pal.colorAtencion.withOpacity(0.15),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(fontWeight: FontWeight.w600, color: pal.colorAtencion),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      minimumSize: WidgetStateProperty.all(const Size.fromHeight(44)),
                      backgroundColor: WidgetStateProperty.all(const Color(0xFFE57373)),
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                      overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.10)),
                      elevation: WidgetStateProperty.all(0),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Aceptar', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
