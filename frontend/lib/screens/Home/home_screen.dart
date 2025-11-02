import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Login/login_screen.dart';
import '../Turnos/misTurnos.dart';
import '../Turnos/reservar_turno.dart';
import '../Turnos/gestion_turnos.dart';
import '../Profesionales/profesionales.dart';
import '../Especialidades/especialidades.dart';
import 'package:flutter_application_1/config/paleta_colores.dart' as pal;
import 'package:flutter_application_1/widgets/barra_nav_inferior.dart';
import 'package:flutter_application_1/widgets/barra_nav_superior.dart';
import '../Perfil/perfil.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;
  int _notifCount = 3; // demo

  // Demo “próximos turnos”
  final List<Appointment> _nextAppointments = const [
    Appointment(especialidad: 'Cardiología', profesional: 'Dra. Lopez', fecha: 'Mar 01, 10:30'),
    Appointment(especialidad: 'Clínica', profesional: 'Dr. Pérez', fecha: 'Mar 05, 09:00'),
    Appointment(especialidad: 'Dermatología', profesional: 'Dra. Ruiz', fecha: 'Mar 12, 15:15'),
  ];

  int _bottomIndex = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: pal.fondo,
      appBar: CustomTopBar.home(
        title: '',
        notifCount: _notifCount,
        onNotificationsPressed: () => setState(() => _notifCount = 0),

        onMenuSelected: (value) async {
          switch (value) {
            case 'mis_turnos':
            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MisTurnosScreen()),
            );
            break;

          case 'historial':
          
          if (!context.mounted) return;
          Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GestionTurnosScreen()),
            );
          break;

          case 'especialidades':
            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EspecialidadesScreen()),
            );
            break;

        case 'profesionales':
          if (!context.mounted) return;
          Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfesionaleScreen()),
            );
        break;

        case 'perfil':
          if (!context.mounted) return;
          Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MiPerfilScreen()),
            );
        break;

        case 'logout':
          // Cerrar sesión  y llevar a Login
          await FirebaseAuth.instance.signOut();
          if (!context.mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        break;
      }
    },

    menuBuilder: (context) => const [
      PopupMenuItem(
        value: 'mis_turnos',
        child: Text('Mis turnos', style: TextStyle(color: Colors.white)),
      ),
      PopupMenuItem(
        value: 'historial',
        child: Text('Historial turnos', style: TextStyle(color: Colors.white)),
      ),
      PopupMenuItem(
        value: 'especialidades',
        child: Text('Especialidades', style: TextStyle(color: Colors.white)),
      ),
      PopupMenuItem(
        value: 'profesionales',
        child: Text('Profesionales', style: TextStyle(color: Colors.white)),
      ),
      PopupMenuItem(
        value: 'perfil',
        child: Text('Mi perfil', style: TextStyle(color: Colors.white)),
      ),
      PopupMenuDivider(),
      PopupMenuItem(
        value: 'logout',
        child: Text(
          'Cerrar sesión',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    ),
  ],
),


      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Image.asset('assets/logo.png', height: 110, fit: BoxFit.contain),
              ),

              // Contenedor celeste con carrusel
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                decoration: BoxDecoration(
                  color: pal.colorSecundario,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Próximos turnos',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),

                    SizedBox(
                      height: 110,
                      child: PageView.builder(
                        controller: _pageCtrl,
                        itemCount: _nextAppointments.length,
                        onPageChanged: (i) => setState(() => _currentPage = i),
                        itemBuilder: (_, i) => _AppointmentCard(app: _nextAppointments[i]),
                      ),
                    ),

                    const SizedBox(height: 12),
                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _nextAppointments.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == i ? 10 : 8,
                          height: _currentPage == i ? 10 : 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            
                            color: _currentPage == i
                                ? pal.colorAcento2.withValues(alpha: 0.9)
                                : pal.colorPrimario.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Accesos rápidos (grid 2x2)
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.18,
                ),
                children: [
                  _QuickButton(
                    icon: Icons.person,
                    label: 'Mi Perfil',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MiPerfilScreen()),
                      );
                    },
                  ),
                  _QuickButton(
                    icon: Icons.event_note,
                    label: 'Mis Turnos',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MisTurnosScreen()),
                      );
                    },
                  ),
                  _QuickButton(
                    icon: Icons.local_hospital,
                    label: 'Especialidades',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EspecialidadesScreen()),
                      );
                    },
                  ),
                  _QuickButton(
                    icon: Icons.groups,
                    label: 'Profesionales',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfesionaleScreen()),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: media.size.height * 0.08),
            ],
          ),
        ),
      ),

      bottomNavigationBar: CustomBottomNav(
      currentIndex: _bottomIndex,
      onDestinationSelected: (i) => setState(() => _bottomIndex = i),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: pal.colorAcento,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReservarTurnoWizard()),
          );
        },
        child: const Icon(Icons.calendar_month),
      ),
    );
  }
}

// ---------------- Widgets de apoyo ----------------

class Appointment {
  final String especialidad;
  final String profesional;
  final String fecha;
  const Appointment({
    required this.especialidad,
    required this.profesional,
    required this.fecha,
  });
}

class _AppointmentCard extends StatelessWidget {
  final Appointment app;
  const _AppointmentCard({required this.app});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: pal.fondo,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${app.especialidad} • ${app.profesional}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(app.fecha, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: pal.colorSecundario,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: pal.colorAcento),
              const SizedBox(height: 10),
              Text(label, textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: pal.colorAtencion,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count > 9 ? '9+' : '$count',
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}


