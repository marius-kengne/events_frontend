import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  DateTime? selectedDate;
  bool isLoading = false;

  void _submit() async {
    if (titleController.text.isEmpty || selectedDate == null) return;

    setState(() => isLoading = true);
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final success = await ApiService().createEvent(
      token!,
      title: titleController.text,
      description: descriptionController.text,
      location: locationController.text,
      date: selectedDate!,
    );

    setState(() => isLoading = false);
    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la création')),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un événement')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Titre')),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
            TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Lieu')),
            Row(
              children: [
                Text(selectedDate == null
                    ? 'Aucune date choisie'
                    : '📅 ${selectedDate!.toLocal().toString().split(' ')[0]}'),
                TextButton(onPressed: _pickDate, child: const Text('Choisir la date'))
              ],
            ),
            const SizedBox(height: 16),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _submit, child: const Text('Créer')),
          ],
        ),
      ),
    );
  }
}
