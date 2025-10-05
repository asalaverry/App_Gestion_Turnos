import 'package:flutter/material.dart';
import 'reservarTurno_4.dart';
import 'reservarTurno_6.dart';

const colorFondo = Color(0xFFF8FAFC);
const colorPrimario = Color(0xFF86B6F6);
const colorAcento = Color(0xFF2C6E7B);

class ReservarTurno_5 extends StatefulWidget {
  const ReservarTurno_5({super.key});

  @override
  State<ReservarTurno_5> createState() => _ReservarTurno_5State();
}

class _ReservarTurno_5State extends State<ReservarTurno_5> {
  DateTime selectedDate = DateTime.now();
  int _bottomIndex = 1;

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text("Reservar Turno 5"),
        backgroundColor: colorPrimario,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ReservarTurno_4()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Seleccioná una fecha"),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _selectDate(context),
              child: Text("${selectedDate.toLocal()}".split(' ')[0]),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ReservarTurno_4()),
                    );
                  },
                  child: const Text("Anterior"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ReservarTurno_6()),
                    );
                  },
                  child: const Text("Siguiente"),
                ),
              ],
            ),
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
                MaterialPageRoute(builder: (_) => const ReservarTurno_4()),
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
          MaterialPageRoute(builder: (_) => const ReservarTurno_6()),
        );
      },
      child: const Icon(Icons.arrow_forward),
    );
  }
}
