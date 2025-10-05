import 'package:flutter/material.dart';
import 'misTurnos.dart';

const colorFondo = Color(0xFFF8FAFC);
const colorPrimario = Color(0xFF86B6F6);
const colorAcento = Color(0xFF2C6E7B);

class ReservarTurno_8 extends StatelessWidget {
  const ReservarTurno_8({super.key});

  final String especialidad = "Odontología";
  final String profesional = "Dr. Pérez";
  final String fecha = "17/08/2023";
  final String horario = "10:00";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text("Turno reservado"),
        backgroundColor: colorPrimario,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.event_available, size: 50, color: Colors.green),
                const SizedBox(height: 16),
                const Text(
                  "Turno reservado exitosamente",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text("Especialidad: $especialidad"),
                Text("Profesional: $profesional"),
                Text("Fecha: $fecha"),
                Text("Horario: $horario"),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Va directamente a MisTurnosScreen
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => const MisTurnosScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text("Aceptar"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
