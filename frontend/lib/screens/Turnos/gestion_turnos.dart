import 'package:flutter/material.dart';
import '../Turnos/reservar_turno.dart';
import 'package:flutter_application_1/config/paleta_colores.dart' as pal;
import 'package:flutter_application_1/widgets/barra_nav_inferior.dart';

/*
const fondo = Color(0xFFF8FAFC);
const colorPrimario = Color(0xFF86B6F6);
const colorSecundario = Color(0xFFEEF5FF);
const colorAcento = Color(0xFF2C6E7B);
const colorAcento2 = Color(0xFF3A8FA0);
const colorFondo = Color(0xFFF8FAFC);
const colorAtencion = Color.fromRGBO(246, 122, 122, 100);
const colorIndicador = Color.fromRGBO(20,107,223,100);
const colorFuente =  Color.fromARGB(179, 96, 96, 96);*/


class Turno {
  final String especialidad;
  final String profesional;
  final String fecha;  
  final String horario; 
  final String? observaciones; // se usa en historial

  Turno({
    required this.especialidad,
    required this.profesional,
    required this.fecha,
    required this.horario,
    this.observaciones,
  });
}


class  GestionTurnosScreen extends StatefulWidget {
  const  GestionTurnosScreen({super.key});

  @override
  State< GestionTurnosScreen> createState() => _GestionTurnosScreen();
}

class _GestionTurnosScreen extends State< GestionTurnosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  // Mocks: reemplazar por datos del backend luego
  final List<Turno> _proximos = [
    Turno(especialidad: 'Clínica Médica', profesional: 'Dr. Pérez', fecha: '15/10/2025', horario: '09:00'),
    Turno(especialidad: 'Cardiología', profesional: 'Dra. López', fecha: '20/10/2025', horario: '10:30'),
    Turno(especialidad: 'Dermatología', profesional: 'Dra. Ruiz', fecha: '28/10/2025', horario: '15:15'),
  ];

  final List<Turno> _historial = [
    Turno(
      especialidad: 'Oftalmología',
      profesional: 'Dr. Gómez',
      fecha: '04/09/2025',
      horario: '11:00',
      observaciones: 'Control anual. Se indicó nuevo aumento.',
    ),
    Turno(
      especialidad: 'Odontología',
      profesional: 'Dra. Navas',
      fecha: '22/08/2025',
      horario: '14:00',
      observaciones: 'Limpieza y control. Sin novedades.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

int _bottomIndex = 1; // marcar Atrás como activo en esta pantalla

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: pal.fondo,

    // AppBar con tabs
    appBar: AppBar(
      backgroundColor: pal.colorPrimario,
      elevation: 0,
      foregroundColor: Colors.white,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: const Text('Turnos'),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: pal.colorSecundario,
          child: TabBar(
            controller: _tabCtrl,
            indicatorColor: pal.colorIndicador,
            labelColor: pal.colorIndicador,
            unselectedLabelColor: pal.colorFuente,
            tabs: const [
              Tab(text: 'Próximos'),
              Tab(text: 'Historial'),
            ],
          ),
        ),
      ),
    ),
    

    // Contenido de cada pestaña
    body: TabBarView(
      controller: _tabCtrl,
      children: [
        _ListaTurnos(
          items: _proximos,
          onTapItem: (t) => _mostrarDetalleProximo(context, t),
        ),
        _ListaTurnos(
          items: _historial,
          onTapItem: (t) => _mostrarDetalleHistorial(context, t),
        ),
      ],
    ),

    // Bottom nav igual al Home
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
              Navigator.of(context).popUntil((route) => route.isFirst); // Home
            } else {
              Navigator.of(context).maybePop(); // Atrás
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Colors.white),
              label: '',
            ),
            NavigationDestination(
              icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
              label: '',
            ),
          ],
        ),
      ),
    ),*/
    bottomNavigationBar: CustomBottomNav(
    currentIndex: _bottomIndex,
    onDestinationSelected: (i) {
    setState(() => _bottomIndex = i);
    if (i == 0) {
      // Ir a Home (raíz de la app)
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      // Atrás
      Navigator.of(context).maybePop();
        }
      },
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: pal.colorAcento,
        foregroundColor: Colors.white,
        onPressed: () {
          // Acceso rápido a "Reservar Turno"
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ReservarTurnoWizard()),
          );
        },
        child: const Icon(Icons.calendar_month),
      ),
  );
}



  // ---------- POPUPS Próximos ----------
  void _mostrarDetalleProximo(BuildContext context, Turno t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: pal.colorSecundario,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header con icono + cerrar
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.calendar_today, color: pal.colorAcento, size: 36),
              ],
            ),
            const SizedBox(height: 10),
            const Text('Datos del turno',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            _DatoLinea(label: 'Especialidad', value: t.especialidad),
            _DatoLinea(label: 'Profesional', value: t.profesional),
            _DatoLinea(label: 'Fecha', value: t.fecha),
            _DatoLinea(label: 'Horario', value: t.horario),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: pal.colorAtencion, // botón rojo suave
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // cierra detalle
                  _confirmarCancelacion(context, t);
                },
                child: const Text('Cancelar turno'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarCancelacion(BuildContext context, Turno t) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: pal.colorSecundario,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        actionsPadding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        title: Row(
          children: const [
            Icon(Icons.error_outline, color: pal.colorAtencion),
            SizedBox(width: 8),
            Expanded(
              child: Text(
              '¿Deseás cancelar este turno?',
              softWrap: true,
            ),
          ),
          ],
        ),
        content: const Text(
          'Si lo cancelás, perderás la reserva de la fecha y el horario seleccionados.',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: pal.colorAcento,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // cierra confirmación
              // Lógica local: quitar de Próximos y pasar a Historial 
              setState(() {
                _proximos.remove(t);
                _historial.insert(
                  0,
                  Turno(
                    especialidad: t.especialidad,
                    profesional: t.profesional,
                    fecha: t.fecha,
                    horario: t.horario,
                    observaciones: 'Turno cancelado por el usuario.',
                  ),
                );
              });
              _exitoCancelacion(context);
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _exitoCancelacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: pal.colorSecundario,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.check_circle_outline, color: pal.colorAcento),
            SizedBox(width: 8),
            Expanded(
              child: Text(
              'Turno cancelado correctamente',
              softWrap: true,
            ),
          ),
        ],
      ),
        content: const Text('Tu turno ha sido cancelado correctamente.'),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: pal.colorAcento,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar'),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- POPUP Historial ----------
  void _mostrarDetalleHistorial(BuildContext context, Turno t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: pal.colorSecundario,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today, color: pal.colorAcento, size: 36),
            const SizedBox(height: 10),
            const Text('Datos del turno',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            _DatoLinea(label: 'Especialidad', value: t.especialidad),
            _DatoLinea(label: 'Profesional', value: t.profesional),
            _DatoLinea(label: 'Fecha', value: t.fecha),
            _DatoLinea(label: 'Horario', value: t.horario),
            if (t.observaciones != null) ...[
              const SizedBox(height: 8),
              _DatoLinea(label: 'Observaciones médicas', value: t.observaciones!),
            ],
          ],
        ),
      ),
    );
  }
}

// ====== Lista y Card reutilizable ======
class _ListaTurnos extends StatelessWidget {
  final List<Turno> items;
  final void Function(Turno) onTapItem;

  const _ListaTurnos({required this.items, required this.onTapItem});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text('No hay turnos para mostrar', style: TextStyle(color: Colors.black54)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final t = items[i];
        return Material(
          color: pal.colorSecundario,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onTapItem(t),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.event_available, color: pal.colorAcento),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.especialidad,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(
                          '${t.profesional}  •  ${t.fecha}  •  ${t.horario}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.black45),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ====== Fila de dato  ======
class _DatoLinea extends StatelessWidget {
  final String label;
  final String value;

  const _DatoLinea({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }
}
