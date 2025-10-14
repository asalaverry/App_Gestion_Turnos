import 'package:flutter/material.dart';
import 'misTurnos.dart';
import '../Home/home_screen.dart';
import 'package:flutter_application_1/config/paleta_colores.dart' as pal;
import 'package:flutter_application_1/widgets/barra_nav_inferior.dart';

/*
const colorFondo = Color(0xFFF8FAFC);
const colorPrimario = Color(0xFF86B6F6);
const colorAcento = Color(0xFF2C6E7B);*/

// ------ Mocks demo ------
const _especialidades = <String>[
  'Clínica Médica', 'Cardiología', 'Dermatología', 'Pediatría',
];
const _profesionalesPorEsp = <String, List<String>>{
  'Clínica Médica': ['Dr. Pérez', 'Dra. Gómez'],
  'Cardiología': ['Dra. López', 'Dr. Romano'],
  'Dermatología': ['Dra. Ruiz'],
  'Pediatría': ['Dra. Sosa', 'Dr. Vidal'],
};
const _horariosBase = <String>[
  '08:30','09:00','09:30','10:00','10:30','11:00','14:00','14:30','15:00','15:30'
];

InputDecoration _inputDecoration({required String hint, required IconData prefix}) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    prefixIcon: Icon(prefix, color: pal.colorAcento),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.black.withOpacity(.25)),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: pal.colorAcento, width: 1.4),
    ),
  );
}

class ReservarTurnoWizard extends StatefulWidget {
  const ReservarTurnoWizard({super.key});
  @override
  State<ReservarTurnoWizard> createState() => _ReservarTurnoWizardState();
}

class _ReservarTurnoWizardState extends State<ReservarTurnoWizard> {
  final _page = PageController();
  int _step = 0;

  // Estado del flujo
  String? _especialidad;
  String? _profesional;
  DateTime? _fecha;
  String? _horario;
  bool _recordatorio24h = false;

  // Habilitaciones
  bool get _okStep0 => _especialidad != null && _profesional != null;
  bool get _okStep1 => _fecha != null && _horario != null;

  // Bottom nav (home / back)
  int _bottomIndex = 1;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: pal.fondo,
      appBar: AppBar(
        title: const Text('Reservar turno'),
        backgroundColor: pal.colorPrimario,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),

      body: PageView(
        controller: _page,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // PASO 0: Especialidad + Profesional
          _StepContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _HeaderIcon(),
                const Text('Seleccioná la especialidad',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _especialidad,
                  items: _especialidades
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() {
                    _especialidad = val;
                    _profesional = null;
                  }),
                  decoration: _inputDecoration(
                    hint: 'Especialidades', prefix: Icons.medical_services_outlined),
                ),
                const SizedBox(height: 22),
                const Text('Seleccioná un profesional',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _profesional,
                  items: (_profesionalesPorEsp[_especialidad] ?? const [])
                      .map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (val) => setState(() => _profesional = val),
                  decoration: _inputDecoration(
                    hint: 'Profesionales', prefix: Icons.person_outline),
                ),
                SizedBox(height: media.size.height * 0.18),
                _PillButtons(
                  anterior: null, // primer paso
                  siguienteEnabled: _okStep0,
                  onSiguiente: () => _go(1),
                ),
              ],
            ),
          ),

          // PASO 1: Fecha + Horario
          _StepContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _HeaderIcon(),
                const Text('Seleccioná una fecha',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: _fecha == null
                        ? 'MM/DD/YYYY'
                        : '${_fecha!.month.toString().padLeft(2,'0')}/${_fecha!.day.toString().padLeft(2,'0')}/${_fecha!.year}',
                  ),
                  decoration: _inputDecoration(hint: 'MM/DD/YYYY', prefix: Icons.event),
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _fecha ?? now,
                      firstDate: now,
                      lastDate: DateTime(now.year + 1),
                      builder: (ctx, child) => Theme(
                        data: Theme.of(ctx).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: pal.colorAcento, onPrimary: Colors.white, onSurface: Colors.black87),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) setState(() => _fecha = picked);
                  },
                ),
                const SizedBox(height: 18),
                const Text('Seleccioná un horario',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _horario,
                  items: _horariosBase
                      .map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
                  onChanged: (val) => setState(() => _horario = val),
                  decoration: _inputDecoration(
                    hint: 'Horarios disponibles', prefix: Icons.schedule),
                ),
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Recordarme 24 hs antes'),
                  value: _recordatorio24h,
                  activeColor: pal.colorAcento,
                  onChanged: (v) => setState(() => _recordatorio24h = v),
                ),
                SizedBox(height: media.size.height * 0.12),
                _PillButtons(
                  anterior: () => _go(0),
                  siguienteEnabled: _okStep1,
                  onSiguiente: () => _go(2),
                ),
              ],
            ),
          ),

          // PASO 2: Resumen
          _StepContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 6),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.event_available, size: 48, color: pal.colorAcento),
                        const SizedBox(height: 12),
                        const Text('Resumen turno',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        _KV('Especialidad', _especialidad ?? '-'),
                        _KV('Profesional', _profesional ?? '-'),
                        _KV('Fecha', _fecha == null
                            ? '-' : '${_fecha!.day}/${_fecha!.month}/${_fecha!.year}'),
                        _KV('Horario', _horario ?? '-'),
                        if (_recordatorio24h) _KV('Recordatorio', '24 horas antes'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _PillButtons(
                  anterior: () => _go(1),
                  siguienteEnabled: true,
                  onSiguiente: () => _go(3), // aquí llamar al backend y si OK -> 3
                  textoSiguiente: 'Confirmar',
                ),
              ],
            ),
          ),

          // PASO 3: Éxito
          _StepContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 1,
                  child: const Padding(
                    padding: EdgeInsets.all(22),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_outline, color: pal.colorAcento, size: 48),
                        SizedBox(height: 12),
                        Text('Turno reservado exitosamente',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pal.colorAcento,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const MisTurnosScreen()),
                        (r) => r.isFirst,
                      );
                    },
                    child: const Text('Aceptar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Barra inferior 
      /*bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: pal.colorPrimario,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            height: 68,
            backgroundColor: pal.colorPrimario,
            indicatorColor: Colors.white.withOpacity(0.08),
            selectedIndex: _bottomIndex,
            onDestinationSelected: (i) {
              setState(() => _bottomIndex = i);
              if (i == 0) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MisTurnosScreen()),
                  (r) => r.isFirst,
                );
              } else {
                Navigator.of(context).maybePop();
              }
            },
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined, color: Colors.white), label: ''),
              NavigationDestination(icon: Icon(Icons.arrow_back_ios_new, color: Colors.white), label: ''),
            ],
          ),
        ),
      ),*/
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _bottomIndex,
        onDestinationSelected: (i) {
        setState(() => _bottomIndex = i);
        if (i == 0) {
        // Ir a Mis Turnos como “Home” de este flujo
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (r) => r.isFirst,
        );
        } else {
          Navigator.of(context).maybePop();
        }
        },
      ),

    );
  }

  void _go(int to) {
    setState(() => _step = to);
    _page.animateToPage(
      to,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }
}

// ---------- Widgets de apoyo ----------
class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Icon(Icons.event_available, size: 72, color: pal.colorAcento),
    );
  }
}

class _StepContainer extends StatelessWidget {
  final Widget child;
  const _StepContainer({required this.child});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20, 16, 20, kBottomNavigationBarHeight + 24), 
      child: child,
    );
  }
}

class _PillButtons extends StatelessWidget {
  final VoidCallback? anterior;
  final VoidCallback? onSiguiente;
  final bool siguienteEnabled;
  final String textoSiguiente;
  const _PillButtons({
    required this.anterior,
    required this.siguienteEnabled,
    required this.onSiguiente,
    this.textoSiguiente = 'Siguiente',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          onPressed: anterior,
          style: OutlinedButton.styleFrom(
            shape: const StadiumBorder(),
            side: BorderSide(color: pal.colorAcento.withOpacity(.7)),
            foregroundColor: pal.colorAcento,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            minimumSize: const Size(140, 44),
          ),
          child: const Text('Anterior'),
        ),
        ElevatedButton(
          onPressed: siguienteEnabled ? onSiguiente : null,
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            backgroundColor: pal.colorAcento,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            minimumSize: const Size(140, 44),
          ),
          child: Text(textoSiguiente),
        ),
      ],
    );
  }
}

Widget _KV(String k, String v) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 6),
  child: Row(
    children: [
      SizedBox(width: 130, child: Text('$k:', style: const TextStyle(fontWeight: FontWeight.w600))),
      Expanded(child: Text(v)),
    ],
  ),
);
