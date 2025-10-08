import 'package:flutter/material.dart';
import '../Turnos/gestion_turnos.dart';
import '../Turnos/reservar_turno.dart';

// ===== Paleta (reutiliza la tuya) =====
const fondo = Color(0xFFF8FAFC);
const colorPrimario = Color(0xFF86B6F6);
const colorSecundario = Color(0xFFEEF5FF);
const colorAcento = Color(0xFF2C6E7B);
const colorAcento2 = Color(0xFF3A8FA0);
const colorFondo = Color(0xFFF8FAFC);
const colorAtencion = Color.fromRGBO(246, 122, 122, 100);

// ===== Pantalla Mis Turnos =====
class MisTurnosScreen extends StatefulWidget {
  const MisTurnosScreen({super.key});

  @override
  State<MisTurnosScreen> createState() => _MisTurnosScreenState();
}

class _MisTurnosScreenState extends State<MisTurnosScreen> {
  int _bottomIndex = 1; 
 

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: colorPrimario,
        elevation: 0,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Mis Turnos'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),

              // Icono + subtítulo
              Column(
                children: const [
                  Icon(Icons.calendar_month, size: 72, color: colorAcento),
                  SizedBox(height: 8),
                  Text(
                    'Seleccionar una opción',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Opción: Reservar turno
              _OptionTile(
                title: 'Reservar Turno',
                subtitle: 'Reserva un nuevo turno',
                icon: Icons.event_available,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ReservarTurnoWizard()),
                  );
                },
              ),

              const SizedBox(height: 14),

              // Opción: Historial de turnos
              _OptionTile(
                title: 'Historial de Turnos',
                subtitle: 'Consultar turnos anteriores',
                icon: Icons.history_edu,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const GestionTurnosScreen()),
                  );
                },
              ),

              SizedBox(height: media.size.height * 0.10),
            ],
          ),
        ),
      ),

      // Bottom nav igual al Home
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorPrimario,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            height: 68,
            backgroundColor: colorPrimario,
            indicatorColor: Colors.white.withOpacity(0.08),
            selectedIndex: _bottomIndex,
            onDestinationSelected: (i) {
              setState(() => _bottomIndex = i);
              if (i == 0) {
                // Home
                Navigator.of(context).popUntil((route) => route.isFirst);
              } else {
                // Atrás
                Navigator.of(context).maybePop();
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorAcento,
        foregroundColor: Colors.white,
        onPressed: () {
          // Acceso rápido a "Reservar Turno"
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ReservarTurnoScreen()),
          );
        },
        child: const Icon(Icons.calendar_month),
      ),
    );
  }
}


class _OptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _OptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorSecundario,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              // Placeholder de icono tipo “imagen”
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: colorAcento),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
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
  }
}


class ReservarTurnoScreen extends StatelessWidget {
  const ReservarTurnoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservar Turno'),
        backgroundColor: colorPrimario,
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text('WIP: Formulario de reserva')),
    );
  }
}

class HistorialTurnosScreen extends StatelessWidget {
  const HistorialTurnosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Turnos'),
        backgroundColor: colorPrimario,
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text('WIP: Listado de turnos previos')),
    );
  }
}
