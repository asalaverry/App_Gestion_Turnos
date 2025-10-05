import 'package:flutter/material.dart';
import 'reservarTurno_3.dart';
import 'reservarTurno_5.dart';

const colorFondo = Color(0xFFF8FAFC);
const colorPrimario = Color(0xFF86B6F6);
const colorAcento = Color(0xFF2C6E7B);

class ReservarTurno_4 extends StatefulWidget {
  const ReservarTurno_4({super.key});

  @override
  State<ReservarTurno_4> createState() => _ReservarTurno_4State();
}

class _ReservarTurno_4State extends State<ReservarTurno_4> {
  TextEditingController _fechaController = TextEditingController();
  TextEditingController _horarioController = TextEditingController();
  bool recordar24h = false;
  int _bottomIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text("Reservar Turno 4"),
        backgroundColor: colorPrimario,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ReservarTurno_3()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _fechaController,
              decoration: const InputDecoration(
                labelText: "Fecha de turno",
                hintText: "MM/DD/YYYY",
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _horarioController,
              decoration: const InputDecoration(
                labelText: "Horarios disponibles",
              ),
            ),
            SwitchListTile(
              title: const Text("Recordarme 24 hs antes"),
              value: recordar24h,
              onChanged: (val) => setState(() => recordar24h = val),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ReservarTurno_3()),
                    );
                  },
                  child: const Text("Anterior"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ReservarTurno_5()),
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
                MaterialPageRoute(builder: (_) => const ReservarTurno_3()),
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
          MaterialPageRoute(builder: (_) => const ReservarTurno_5()),
        );
      },
      child: const Icon(Icons.arrow_forward),
    );
  }
}
