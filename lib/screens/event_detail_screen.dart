import 'package:flutter/material.dart';
import '../models/event.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📍 Lieu: ${event.location ?? 'Non précisé'}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("📅 Date: ${event.date?.toLocal().toString().split(' ')[0] ?? 'Non précisée'}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("✉️ Organisateur: ${event.organizerEmail ?? 'Inconnu'}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("📝 Description:\n${event.description ?? 'Aucune description'}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text(
              event.published ? "✅ Publié" : "❌ Non publié",
              style: TextStyle(
                color: event.published ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
