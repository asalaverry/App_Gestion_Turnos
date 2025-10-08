import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Login/login_screen.dart';
import '../Turnos/misTurnos.dart';
import '../Turnos/reservar_turno.dart';



// Paleta
const fondo = Color(0xFFF8FAFC);
const colorPrimario = Color(0xFF86B6F6);
const colorSecundario = Color(0xFFEEF5FF);
const colorAcento = Color(0xFF2C6E7B);
const colorAcento2 = Color(0xFF3A8FA0);
const kFondo = Color(0xFFF8FAFC);
const colorAtencion = Color.fromRGBO(246, 122, 122, 100);

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
      backgroundColor: fondo,
      appBar: AppBar(
        backgroundColor: colorPrimario,
        elevation: 0,
        foregroundColor: fondo,
        titleSpacing: 0,
        leading: PopupMenuButton<String>(
          icon: const Icon(Icons.menu),
          position: PopupMenuPosition.under,           // aparece debajo del botón
          offset: const Offset(0, 8),                  // separaxion
          color: colorPrimario,                        // fondo azul como la barra
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          onSelected: (value) async {
            switch (value) {
              case 'mis_turnos':
                // Navigator.push(context, MaterialPageRoute(builder: (_) => const MisTurnosScreen()));
                break;
              case 'historial':
                break;
              case 'especialidades':
                break;
              case 'profesionales':
                break;
              case 'perfil':
                break;
              case 'logout':
        
                await FirebaseAuth.instance.signOut();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'mis_turnos',      child: const Text('Mis turnos',        style: TextStyle(color: Colors.white))),
            PopupMenuItem(value: 'historial',       child: const Text('Historial turnos',  style: TextStyle(color: Colors.white))),
            PopupMenuItem(value: 'especialidades',  child: const Text('Especialidades',    style: TextStyle(color: Colors.white))),
            PopupMenuItem(value: 'profesionales',   child: const Text('Profesionales',     style: TextStyle(color: Colors.white))),
            PopupMenuItem(value: 'perfil',          child: const Text('Mi perfil',         style: TextStyle(color: Colors.white))),
            const PopupMenuDivider(),
            PopupMenuItem(value: 'logout',          child: const Text('Cerrar sesión',     style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
          ],
        ),
        title: const Text(''),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {
                  setState(() => _notifCount = 0);
                },
              ),
              if (_notifCount > 0)
                const Positioned(
                  right: 10,
                  top: 10,
                  child: _Badge(count: 3),
                ),
            ],
          ),
          const SizedBox(width: 8),
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
                  color: colorSecundario,
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
                                ? colorAcento2.withValues(alpha: 0.9)
                                : colorPrimario.withValues(alpha: 0.6),
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
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Ir a Mi Perfil')));
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
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Ir a Especialidades')));
                    },
                  ),
                  _QuickButton(
                    icon: Icons.groups,
                    label: 'Profesionales',
                    onTap: () {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Ir a Profesionales')));
                    },
                  ),
                ],
              ),

              SizedBox(height: media.size.height * 0.08),
            ],
          ),
        ),
      ),

      // Bottom nav
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorPrimario,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            height: 68,
            backgroundColor: colorPrimario,
            indicatorColor: Colors.white.withValues(alpha: 0.08),
            selectedIndex: _bottomIndex,
            onDestinationSelected: (i) => setState(() => _bottomIndex = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined, color: Colors.white), label: ''),
              NavigationDestination(icon: Icon(Icons.arrow_back_ios_new, color: Colors.white), label: ''),
            ],
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorAcento,
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
      color: fondo,
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
      color: colorSecundario,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: colorAcento),
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
        color: colorAtencion,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count > 9 ? '9+' : '$count',
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}


