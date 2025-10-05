import 'package:flutter/material.dart';
import 'reservarTurno_6.dart';
import 'reservarTurno_8.dart';

const colorFondo = Color(0xFFF8FAFC);
const colorPrimario = Color(0xFF86B6F6);
const colorAcento = Color(0xFF2C6E7B);

class ReservarTurno_7 extends StatefulWidget {
  const ReservarTurno_7({super.key});

  @override
  State<ReservarTurno_7> createState() => _ReservarTurno_7State();
}

class _ReservarTurno_7State extends State<ReservarTurno_7> {
  int _bottomIndex = 1;

  final String especialidad = "Odontología";
  final String profesional = "Dr. Pérez";
  final String fecha = "17/08/2023";
  final String horario = "10:00";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text("Resumen Turno"),
        backgroundColor: colorPrimario,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ReservarTurno_6()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Resumen turno",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text("Especialidad: $especialidad"),
            Text("Profesional: $profesional"),
            Text("Fecha: $fecha"),
            Text("Horario: $horario"),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ReservarTurno_6()),
                    );
                  },
                  child: const Text("Anterior"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ReservarTurno_8()),
                    );
                  },
                  child: const Text("Confirmar"),
                ),
              ],
            )
          ],
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
                MaterialPageRoute(builder: (_) => const ReservarTurno_6()),
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
          MaterialPageRoute(builder: (_) => const ReservarTurno_8()),
        );
      },
      child: const Icon(Icons.arrow_forward),
    );
  }
}
