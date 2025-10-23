import 'package:flutter/material.dart';
import '../../services/registration_service.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Reemplaza por un eventId real si quieres ver un conteo en vivo
    const eventId = 'EVENT_ID_EJEMPLO';
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reportes rápidos', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.people_outline, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StreamBuilder<int>(
                      stream: RegistrationService().countForEvent(eventId),
                      builder: (context, snap) {
                        final n = snap.data ?? 0;
                        return Text('Inscritos en $eventId: $n');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
