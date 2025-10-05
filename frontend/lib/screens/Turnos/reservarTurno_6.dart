import 'package:flutter/material.dart';
import 'reservarTurno_5.dart';
import 'reservarTurno_7.dart';

const colorFondo = Color(0xFFF8FAFC);
const colorPrimario = Color(0xFF86B6F6);
const colorAcento = Color(0xFF2C6E7B);

class ReservarTurno_6 extends StatefulWidget {
  const ReservarTurno_6({super.key});

  @override
  State<ReservarTurno_6> createState() => _ReservarTurno_6State();
}

class _ReservarTurno_6State extends State<ReservarTurno_6> {
  String? selectedHorario;
  int _bottomIndex = 1;

  List<String> horarios = ["08:00", "09:00", "10:00", "11:00", "12:00", "13:00"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text("Reservar Turno 6"),
        backgroundColor: colorPrimario,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ReservarTurno_5()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedHorario,
              hint: const Text("Seleccioná un horario"),
              onChanged: (val) => setState(() => selectedHorario = val),
              items: horarios
                  .map((h) => DropdownMenuItem(
                        value: h,
                        child: Text(h),
                      ))
                  .toList(),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ReservarTurno_5()),
                    );
                  },
                  child: const Text("Anterior"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ReservarTurno_7()),
                    );
                  },
                  child: const Text("Siguiente"),
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
                MaterialPageRoute(builder: (_) => const ReservarTurno_5()),
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
          MaterialPageRoute(builder: (_) => const ReservarTurno_7()),
        );
      },
      child: const Icon(Icons.arrow_forward),
    );
  }
}
