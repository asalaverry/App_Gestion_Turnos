import 'package:flutter/material.dart';
import 'registro_2.dart';


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

  // Paso 2
  final _obraCtrl = TextEditingController();
  final _afiliadoCtrl = TextEditingController();
  final _planCtrl = TextEditingController();
  final _telCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this)..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    _docCtrl.dispose();
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _obraCtrl.dispose();
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
      initialDate: DateTime(now.year - 25, now.month, now.day),
      firstDate: first,
      lastDate: last,
      helpText: 'Fecha de Nacimiento',
      fieldLabelText: 'MM/DD/YYYY',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: colorAcento,
                  secondary: colorAcento,
                  surface: colorSecundario,
                ),
            dialogBackgroundColor: colorSecundario,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _fechaNac = picked);
  }

  String _fmtFecha(DateTime? d) {
    if (d == null) return '';
    return '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year.toString()}';
  }

  void _nextOrSave() {
    if (_tabs.index == 0) {
      if (_formPersonalesKey.currentState!.validate()) {
        if (_fechaNac == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Seleccioná la fecha de nacimiento')),
          );
          return;
        }
        _tabs.animateTo(1);
      }
    } else {
      if (_formCoberturaKey.currentState!.validate()) {
          Navigator.push(
          context,
          MaterialPageRoute(
          builder: (_) => RegisterStep2Screen(
          nombre: _nombreCtrl.text, // pasar el nombre escrito
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
        focusedBorder: _tfBorder(colorPrimario),
        suffixIcon: suffix,
        floatingLabelStyle: const TextStyle(color: colorPrimario),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brandTextStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colorPrimario, fontWeight: FontWeight.w600, letterSpacing: .2,
    );

    return Scaffold(
      backgroundColor: colorFondo,
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
                              color: colorSecundario, 
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
                                      _DatosPersonalesForm(
                                        formKey: _formPersonalesKey,
                                        docCtrl: _docCtrl,
                                        nombreCtrl: _nombreCtrl,
                                        apellidoCtrl: _apellidoCtrl,
                                        fechaNac: _fechaNac,
                                        onPickFecha: _pickFecha,
                                        fmt: _fmtFecha,
                                        dec: _dec,
                                      ),
                                      _CoberturaForm(
                                        formKey: _formCoberturaKey,
                                        obraCtrl: _obraCtrl,
                                        afiliadoCtrl: _afiliadoCtrl,
                                        planCtrl: _planCtrl,
                                        telCtrl: _telCtrl,
                                        dec: _dec,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: colorAcento),
                                          shape: const StadiumBorder(),
                                          foregroundColor: colorAcento,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                        ),
                                        child: const Text('Cancelar'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                      onPressed: () {
                                      if (_tabs.index == 0) {
                                            _nextOrSave(); // cambia de Datos Personales → Cobertura
                                      } else {
                                      if (_formCoberturaKey.currentState!.validate()) {
                                        Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => RegisterStep2Screen(
                                          nombre: _nombreCtrl.text, //  pasa el nombre ingresado
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                backgroundColor: colorAcento,
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
          labelColor: colorAcento,
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

  const _DatosPersonalesForm({
    required this.formKey,
    required this.docCtrl,
    required this.nombreCtrl,
    required this.apellidoCtrl,
    required this.fechaNac,
    required this.onPickFecha,
    required this.fmt,
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
            decoration: dec('Documento'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresá tu DNI' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: nombreCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: dec('Nombre'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresá tu nombre' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: apellidoCtrl,
            textCapitalization: TextCapitalization.words,
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
  final TextEditingController obraCtrl;
  final TextEditingController afiliadoCtrl;
  final TextEditingController planCtrl;
  final TextEditingController telCtrl;
  final InputDecoration Function(String, {Widget? suffix}) dec;

  const _CoberturaForm({
    required this.formKey,
    required this.obraCtrl,
    required this.afiliadoCtrl,
    required this.planCtrl,
    required this.telCtrl,
    required this.dec,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: obraCtrl.text.isNotEmpty ? obraCtrl.text : null,
            decoration: dec('Obra Social'),
            items: const [
              DropdownMenuItem(value: 'OSDE', child: Text('OSDE')),
              DropdownMenuItem(value: 'Swiss Medical', child: Text('Swiss Medical')),
              DropdownMenuItem(value: 'Galeno', child: Text('Galeno')),
              DropdownMenuItem(value: 'Medicus', child: Text('Medicus')),
              DropdownMenuItem(value: 'No tengo obra social', child: Text('No tengo obra social')),
            ],
            onChanged: (val) {
              obraCtrl.text = val ?? '';
            },
            validator: (v) => (v == null || v.isEmpty) ? 'Seleccioná tu cobertura' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: afiliadoCtrl,
            decoration: dec('Nº de Afiliado'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresá tu Nº de afiliado' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: planCtrl,
            decoration: dec('Plan'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
