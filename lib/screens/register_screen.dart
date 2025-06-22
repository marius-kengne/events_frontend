import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String role = 'ROLE_USER';
  bool isLoading = false;

  void _register() async {
    setState(() => isLoading = true);
    final success = await Provider.of<AuthProvider>(context, listen: false)
        .register(emailController.text, passwordController.text, role);

    setState(() => isLoading = false);

    if (success) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            DropdownButton<String>(
              value: role,
              items: const [
                DropdownMenuItem(value: 'ROLE_USER', child: Text('User')),
                DropdownMenuItem(value: 'ROLE_ORGANIZER', child: Text('Organizer')),
              ],
              onChanged: (value) => setState(() => role = value!),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _register, child: const Text('Register')),
          ],
        ),
      ),
    );
  }
}
