import 'package:flutter/material.dart';
import 'misTurnos.dart';
import 'reservarTurno_2.dart';

// Paleta de colores
const colorFondo = Color(0xFFF8FAFC);
const colorPrimario = Color(0xFF86B6F6);
const colorAcento = Color(0xFF2C6E7B);

class ReservarTurno_1 extends StatefulWidget {
  const ReservarTurno_1({super.key});

  @override
  State<ReservarTurno_1> createState() => _ReservarTurno_1State();
}

class _ReservarTurno_1State extends State<ReservarTurno_1> {
  int _bottomIndex = 1;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text('Reservar Turno 1'),
        backgroundColor: colorPrimario,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MisTurnosScreen()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Column(
                children: const [
                  Icon(Icons.event_available, size: 72, color: colorAcento),
                  SizedBox(height: 8),
                  Text(
                    'Formulario de reserva 1',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SizedBox(height: media.size.height * 0.10),
              // Aquí irían los campos de formulario
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bottomNav(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _fab(),
    );
  }

  Widget _bottomNav() {
    return Container(
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MisTurnosScreen()),
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
    );
  }

  Widget _fab() {
    return FloatingActionButton(
      backgroundColor: colorAcento,
      foregroundColor: Colors.white,
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ReservarTurno_2()),
        );
      },
      child: const Icon(Icons.arrow_forward),
    );
  }
}
