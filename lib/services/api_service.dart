import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';

  // 🔐 LOGIN
  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': email, 'password': password}),
    );

    print("📥 Login status: ${response.statusCode}");
    print("📄 Login body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    }
    return null;
  }

  // 👤 REGISTER
  Future<bool> register(String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'roles': [role],
      }),
    );
    return response.statusCode == 201;
  }

  // 📦 FETCH EVENTS
  Future<List<Event>> fetchEvents(String token) async {
    final url = Uri.parse('$baseUrl/events');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("🎫 Token utilisé pour fetchEvents : $token");
    print("📥 Response status: ${response.statusCode}");
    print("📄 Response body: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => Event.fromJson(e)).toList();
    } else {
      throw Exception('Erreur lors du chargement des événements');
    }
  }

  // 🚀 CREATE EVENT
  Future<bool> createEvent(
      String token, {
        required String title,
        String? description,
        String? location,
        required DateTime date,
      }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/events'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'location': location,
        'date': date.toIso8601String(),
      }),
    );

    print("📦 Création status: ${response.statusCode}");
    print("📦 Création body: ${response.body}");

    return response.statusCode == 201;
  }

  // PUBLISH EVENT
  Future<bool> publishEvent(String token, int eventId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/events/$eventId/publish'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("📢 Publication status: ${response.statusCode}");
    print("📢 Publication body: ${response.body}");

    return response.statusCode == 200;
  }

  // DELETE EVENT
  Future<bool> deleteEvent(int id, String token) async {
    final url = Uri.parse('$baseUrl/events/$id');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("🗑️ DELETE status: ${response.statusCode}");
    return response.statusCode == 200;
  }

}
