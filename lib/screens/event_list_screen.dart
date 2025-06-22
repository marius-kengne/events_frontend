import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'event_detail_screen.dart';
import 'create_event_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  List<Event> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final auth = context.read<AuthProvider>();
    if (auth.token == null) return;

    try {
      final events = await ApiService().fetchEvents(auth.token!);
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      print("❌ Erreur lors du chargement : $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _publishEvent(int id) async {
    final auth = context.read<AuthProvider>();
    try {
      final success = await ApiService().publishEvent(auth.token!, id);
      if (success) {
        _loadEvents();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Événement publié')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Erreur de publication')));
      }
    } catch (e) {
      print("❌ $e");
    }
  }

  Future<void> _deleteEvent(int id) async {
    final auth = context.read<AuthProvider>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: const Text("Voulez-vous vraiment supprimer cet événement ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Annuler")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Supprimer")),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ApiService().deleteEvent(id, auth.token!);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🗑️ Événement supprimé")));
        _loadEvents();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("❌ Échec de la suppression")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOrganizer = context.watch<AuthProvider>().isOrganizer;
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des événements'),
        actions: [
          if (isOrganizer)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateEventScreen()),
                ).then((_) => _loadEvents());
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmation'),
                  content: const Text('Voulez-vous vraiment vous déconnecter ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () {
                        authProvider.clearToken();
                        Navigator.of(context).pop();
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                      },
                      child: const Text('Déconnexion'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadEvents,
        child: ListView.builder(
          itemCount: _events.length,
          itemBuilder: (context, index) {
            final event = _events[index];
            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                title: Text(event.title),
                subtitle: Text(
                  event.published ? '✅ Publié' : '⏳ Non publié',
                  style: TextStyle(
                    color: event.published ? Colors.green : Colors.orange,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventDetailScreen(event: event),
                          ),
                        );
                      },
                      child: const Text('Voir détails'),
                    ),
                    if (isOrganizer && !event.published)
                      TextButton(
                        onPressed: () => _publishEvent(event.id),
                        child: const Text('Publier'),
                      ),
                    if (isOrganizer)
                      TextButton(
                        onPressed: () => _deleteEvent(event.id),
                        child: const Text(
                          'Supprimer',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
