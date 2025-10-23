import 'package:flutter/material.dart';

// Widgets de listas
import 'widgets/event_list.dart' show EventList;
import 'widgets/session_list.dart' show SessionList;
import 'widgets/speaker_list.dart' show SpeakerList;

// Formularios en diálogo
import 'forms/event_form.dart' show EventFormDialog;
import 'forms/session_form.dart' show SessionFormDialog;
import 'forms/speaker_form.dart' show SpeakerFormDialog;

// Reportes
import '../reports/reports_screen.dart' show ReportsScreen;

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _idx = 0;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 1100;
    return Scaffold(
      appBar: AppBar(title: const Text('Panel — Admin EPIS')),
      body: Row(
        children: [
          NavigationRail(
            extended: wide,
            selectedIndex: _idx,
            onDestinationSelected: (i) => setState(() => _idx = i),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.event_outlined),
                label: Text('Eventos'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.mic_none),
                label: Text('Ponencias'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.record_voice_over_outlined),
                label: Text('Ponentes'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.query_stats_outlined),
                label: Text('Reportes'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _buildPage()),
        ],
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  Widget _buildPage() {
    switch (_idx) {
      case 0:
        return const EventList();
      case 1:
        return const SessionList();
      case 2:
        return const SpeakerList();
      default:
        return const ReportsScreen();
    }
  }

  Widget? _buildFab(BuildContext context) {
    switch (_idx) {
      case 0:
        return FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('Evento'),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const EventFormDialog(),
          ),
        );
      case 1:
        return FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('Ponencia'),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const SessionFormDialog(),
          ),
        );
      case 2:
        return FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('Ponente'),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const SpeakerFormDialog(),
          ),
        );
      default:
        return null;
    }
  }
}
