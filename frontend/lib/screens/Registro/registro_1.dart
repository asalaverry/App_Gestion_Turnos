import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'registro_2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api.dart';
import 'package:flutter_application_1/config/paleta_colores.dart' as pal;


const fondo = Color(0xFFF8FAFC);
const colorPrimario = Color(0xFF86B6F6); 
const colorSecundario = Color(0xFFEEF5FF); 
const colorAcento = Color(0xFF2C6E7B);
const colorFondo = Color(0xFFF8FAFC);
const colorAcento2 = Color(0xFF3A8FA0);


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;


  // Claves de formularios
  final _formPersonalesKey = GlobalKey<FormState>();
  final _formCoberturaKey = GlobalKey<FormState>();

  // Paso 1
  final _docCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  DateTime? _fechaNac;
  String? _dniError;
  String? _fechaError;


  // Paso 2
  int? _obraSocialId; // ID de la obra social seleccionada
  List<ObraSocial> _obrasSociales = []; // Lista de obras sociales desde la DB
  bool _loadingObras = false; // Estado de carga
  final _afiliadoCtrl = TextEditingController();
  final _planCtrl = TextEditingController();
  final _telCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this)..addListener(() {
      setState(() {});
      // Cargar obras sociales cuando se mueve al tab 2
      if (_tabs.index == 1 && _obrasSociales.isEmpty) {
        _cargarObrasSociales();
      }
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    _docCtrl.dispose();
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _afiliadoCtrl.dispose();
    _planCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFecha() async {
    final now = DateTime.now();
    final first = DateTime(now.year - 120, 1, 1);
    final last = now;

    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: first,
      lastDate: last,
      helpText: 'Fecha de Nacimiento',
      fieldLabelText: 'MM/DD/YYYY',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: pal.colorAcento,
                  secondary: pal.colorAcento,
                  surface: pal.colorSecundario,
                ), dialogTheme: DialogThemeData(backgroundColor: pal.colorSecundario),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _fechaNac = picked;
        _fechaError = null; // Limpiar el error cuando se selecciona una fecha
      });
    }
  }

  String _fmtFecha(DateTime? d) {
    if (d == null) return '';
    return '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year.toString()}';
  }

  /// Cargar obras sociales desde la base de datos
  Future<void> _cargarObrasSociales() async {
    setState(() {
      _loadingObras = true;
    });

    try {
      final res = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/obras-sociales/"),
        headers: {"Content-Type": "application/json"},
      );

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        setState(() {
          _obrasSociales = data.map((json) => ObraSocial.fromJson(json)).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al cargar obras sociales")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
    } finally {
      setState(() {
        _loadingObras = false;
      });
    }
  }

  Future<bool> _checkDni() async {
    final dni = _docCtrl.text.trim();
    
    // Limpiar cualquier error previo al inicio
    setState(() {
      _dniError = null;
    });

    try {
      final res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/usuarios/check"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"documento": dni}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["exists"] == true) {
          setState(() {
            _dniError = "Este DNI ya está registrado";
          });
          return false; // DNI ya existe, no puede continuar
        } else {
          // El DNI está libre, ya limpiamos _dniError al inicio
          return true; // DNI libre, puede continuar
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al validar DNI")),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
      return false;
    }
  }


  void _nextOrSave() async {
    if (_tabs.index == 0) {
      // Verificar fecha de nacimiento
      if (_fechaNac == null) {
        setState(() {
          _fechaError = 'Seleccioná la fecha de nacimiento';
        });
      } else {
        setState(() {
          _fechaError = null;
        });
      }
      
      // Verificar el DNI en el backend
      final dniLibre = await _checkDni();
      
      // Esperar a que Flutter procese el setState antes de validar
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Validar el formulario
      if (!_formPersonalesKey.currentState!.validate()) {
        return; // Si hay errores (campos vacíos, DNI duplicado o fecha faltante), no avanza
      }
      
      // Si todo está OK, avanzar al paso 2
      if (dniLibre) {
        _tabs.animateTo(1);
      }
    } else {
      if (_formCoberturaKey.currentState!.validate()) {
        // Si seleccionó "No tengo obra social" (-1), pasar todo como NULL
        final noTieneObraSocial = _obraSocialId == -1;
        
        final usuarioRegistro = UsuarioRegistro(
          nombre: _nombreCtrl.text.trim(),
          apellido: _apellidoCtrl.text.trim(),
          documento: _docCtrl.text.trim(),
          fechaNacimiento: _fechaNac != null 
            ? '${_fechaNac!.year}-${_fechaNac!.month.toString().padLeft(2, '0')}-${_fechaNac!.day.toString().padLeft(2, '0')}'
            : '',
          obraSocial: noTieneObraSocial ? null : _obraSocialId, // NULL si no tiene obra social
          planObraSocial: noTieneObraSocial ? null : (_planCtrl.text.trim().isNotEmpty ? _planCtrl.text.trim() : null),
          numeroAfiliado: noTieneObraSocial ? null : (_afiliadoCtrl.text.trim().isNotEmpty ? _afiliadoCtrl.text.trim() : null),
        );

        // Navegar a la siguiente pantalla pasando el objeto usuarioRegistro
        Navigator.push(
          context,
          MaterialPageRoute(
          builder: (_) => RegisterStep2Screen(
            usuarioRegistro: usuarioRegistro,
            ),
          ),
        );
      }
    }
  }

  // Helpers para bordes de los TextFields con foco #86B6F6
  OutlineInputBorder _tfBorder([Color? c]) => OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: c ?? Colors.black26, width: 1.2),
      );

  InputDecoration _dec(String label, {Widget? suffix}) => InputDecoration(
        labelText: label,
        border: _tfBorder(),
        enabledBorder: _tfBorder(),
        focusedBorder: _tfBorder(pal.colorPrimario),
        suffixIcon: suffix,
        floatingLabelStyle: const TextStyle(color: pal.colorPrimario),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brandTextStyle = theme.textTheme.bodyMedium?.copyWith(
      color: pal.colorPrimario, fontWeight: FontWeight.w600, letterSpacing: .2,
    );

    return Scaffold(
      backgroundColor: pal.fondo,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxW = constraints.maxWidth;
            final cardW = maxW > 480 ? 420.0 : maxW * .9;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo (asegurate de tenerlo en assets y pubspec.yaml)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Image.asset(
                        'assets/logo.png',
                        height: 140,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Card + Solapitas
                    SizedBox(
                      width: cardW,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Card (fondo EEF5FF)
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 64, 16, 16), // ↑ más aire alto
                            decoration: BoxDecoration(
                              color: pal.colorSecundario, 
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                              border: Border.all(color: Colors.black.withOpacity(0.06)),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 320,
                                  child: TabBarView(
                                    controller: _tabs,
                                    physics: const NeverScrollableScrollPhysics(),
                                    children: [
                                      SingleChildScrollView(
                                        child: _DatosPersonalesForm(
                                          formKey: _formPersonalesKey,
                                          docCtrl: _docCtrl,
                                          nombreCtrl: _nombreCtrl,
                                          apellidoCtrl: _apellidoCtrl,
                                          fechaNac: _fechaNac,
                                          onPickFecha: _pickFecha,
                                          fmt: _fmtFecha,
                                          dec: _dec,
                                          dniError: _dniError,
                                          fechaError: _fechaError,
                                        ),
                                      ),
                                      SingleChildScrollView(
                                        child: _CoberturaForm(
                                          formKey: _formCoberturaKey,
                                          obraSocialId: _obraSocialId,
                                          onObraSocialChanged: (id) {
                                            setState(() {
                                              _obraSocialId = id;
                                              // Si selecciona "No tengo obra social", limpiar los campos
                                              if (id == -1) {
                                                _afiliadoCtrl.clear();
                                                _planCtrl.clear();
                                              }
                                            });
                                          },
                                          obrasSociales: _obrasSociales,
                                          loadingObras: _loadingObras,
                                          afiliadoCtrl: _afiliadoCtrl,
                                          planCtrl: _planCtrl,
                                          telCtrl: _telCtrl,
                                          dec: _dec,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          if (_tabs.index == 0) {
                                            // En el paso 1, cancelar el registro completo
                                            Navigator.pop(context);
                                          } else {
                                            // En el paso 2, volver al paso 1
                                            _tabs.animateTo(0);
                                          }
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: pal.colorAcento),
                                          shape: const StadiumBorder(),
                                          foregroundColor: pal.colorAcento,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                        ),
                                        child: Text(_tabs.index == 0 ? 'Cancelar' : 'Atrás'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _nextOrSave,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: pal.colorAcento,
                                        foregroundColor: Colors.white,
                                        shape: const StadiumBorder(),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                        child: Text(_tabs.index == 0 ? 'Siguiente' : 'Confirmar'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Tabs: mismo ancho que el rectángulo y separadas
                          Positioned(
                            top: -2, // casi pegado al borde superior del rectángulo
                            left: 0,
                            right: 0,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: SizedBox(
                                width: cardW, // se adapta al ancho de la card
                                child: _TabsFichas(
                                  controller: _tabs,
                                  labels: const ['Datos personales', 'Cobertura Médica'],
                                  textStyle: brandTextStyle,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Tabs
class _TabsFichas extends StatelessWidget {
  final TabController controller;
  final List<String> labels;
  final TextStyle? textStyle;

  const _TabsFichas({
    required this.controller,
    required this.labels,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            /*boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],*/
            border: Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          child: TabBar(
            controller: controller,
            labelPadding: const EdgeInsets.symmetric(horizontal: 12),
            indicator: BoxDecoration(
              color: colorPrimario.withOpacity(.12),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: colorPrimario.withOpacity(.5)),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: pal.colorAcento,
            unselectedLabelColor: Colors.black54,
            tabs: labels.map((t) {
              return Tab(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8),
                  child: Text(t, style: textStyle),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// FORM 1 – Datos Personales
class _DatosPersonalesForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController docCtrl;
  final TextEditingController nombreCtrl;
  final TextEditingController apellidoCtrl;
  final DateTime? fechaNac;
  final VoidCallback onPickFecha;
  final String Function(DateTime?) fmt;
  final InputDecoration Function(String, {Widget? suffix}) dec;
  final String? dniError;
  final String? fechaError;

  const _DatosPersonalesForm({
    required this.formKey,
    required this.docCtrl,
    required this.nombreCtrl,
    required this.apellidoCtrl,
    required this.fechaNac,
    required this.onPickFecha,
    required this.fmt,
    this.dniError,
    this.fechaError,
    required this.dec,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: docCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: dec('Documento'),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Ingresá tu DNI';
              }
              // Si hay un error de DNI duplicado, mostrarlo
              if (dniError != null) {
                return dniError;
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: nombreCtrl,
            textCapitalization: TextCapitalization.words,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'))],
            decoration: dec('Nombre'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresá tu nombre' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: apellidoCtrl,
            textCapitalization: TextCapitalization.words,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'))],
            decoration: dec('Apellido'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresá tu apellido' : null,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onPickFecha,
            child: AbsorbPointer(
              child: TextFormField(
                decoration: dec('Fecha de Nacimiento', suffix: const Icon(Icons.calendar_today_outlined)),
                controller: TextEditingController(text: fmt(fechaNac)),
                validator: (v) {
                  if (fechaError != null) {
                    return fechaError;
                  }
                  return null;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// FORM 2 – Cobertura Médica
class _CoberturaForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final int? obraSocialId;
  final Function(int?) onObraSocialChanged;
  final List<ObraSocial> obrasSociales;
  final bool loadingObras;
  final TextEditingController afiliadoCtrl;
  final TextEditingController planCtrl;
  final TextEditingController telCtrl;
  final InputDecoration Function(String, {Widget? suffix}) dec;

  const _CoberturaForm({
    required this.formKey,
    required this.obraSocialId,
    required this.onObraSocialChanged,
    required this.obrasSociales,
    required this.loadingObras,
    required this.afiliadoCtrl,
    required this.planCtrl,
    required this.telCtrl,
    required this.dec,
  });

  @override
  Widget build(BuildContext context) {
    // Verificar si "No tengo obra social" está seleccionado (valor -1)
    final noTieneObraSocial = obraSocialId == -1;

    return Form(
      key: formKey,
      child: Column(
        children: [
          // Dropdown con obras sociales desde la DB
          loadingObras
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              : DropdownButtonFormField<int>(
                  initialValue: obraSocialId,
                  decoration: dec('Obra Social'),
                  hint: const Text('Seleccioná tu obra social'),
                  items: [
                    // Primera opción: "No tengo obra social" con valor -1
                    const DropdownMenuItem<int>(
                      value: -1,
                      child: Text('No tengo obra social'),
                    ),
                    // Resto de las obras sociales de la DB
                    ...obrasSociales.map((obra) {
                      return DropdownMenuItem<int>(
                        value: obra.id,
                        child: Text(obra.nombre),
                      );
                    }),
                  ],
                  onChanged: onObraSocialChanged,
                  validator: (v) => v == null ? 'Seleccioná una opción' : null,
                ),
          const SizedBox(height: 12),
          TextFormField(
            controller: afiliadoCtrl,
            enabled: !noTieneObraSocial, // Deshabilitar si no tiene obra social
            decoration: dec('Nº de Afiliado').copyWith(
              filled: noTieneObraSocial,
              fillColor: noTieneObraSocial ? const Color.fromARGB(255, 216, 225, 236) : null,
            ),
            validator: (v) {
              // Solo validar si tiene obra social
              if (!noTieneObraSocial && (v == null || v.trim().isEmpty)) {
                return 'Ingresá tu Nº de afiliado';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: planCtrl,
            enabled: !noTieneObraSocial, // Deshabilitar si no tiene obra social
            decoration: dec('Plan').copyWith(
              filled: noTieneObraSocial,
              fillColor: noTieneObraSocial ? const Color.fromARGB(255, 216, 225, 236) : null,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}


// Modelo para Obra Social
class ObraSocial {
  final int id;
  final String nombre;

  ObraSocial({required this.id, required this.nombre});

  factory ObraSocial.fromJson(Map<String, dynamic> json) {
    return ObraSocial(
      id: json['id'],
      nombre: json['nombre'],
    );
  }
}

// Modelo de datos para el registro de un usuario
class UsuarioRegistro {
  String nombre;
  String apellido;
  String documento;
  String fechaNacimiento;
  int? obraSocial; // Ahora es int (ID de la obra social)
  String? planObraSocial;
  String? numeroAfiliado;

  UsuarioRegistro({
    required this.nombre,
    required this.apellido,
    required this.documento,
    required this.fechaNacimiento,
    this.obraSocial,
    this.planObraSocial,
    this.numeroAfiliado,
  });

  Map<String, dynamic> toJson() => {
    "nombre": nombre,
    "apellido": apellido,
    "documento": documento,
    "fecha_nacimiento": fechaNacimiento,
    "id_obra_social": obraSocial,
    "plan_obra_social": planObraSocial,
    "nro_afiliado": numeroAfiliado, // Corregido: nro_afiliado con guión bajo
  };
}

