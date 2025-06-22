import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/event_list_screen.dart';
import 'screens/event_detail_screen.dart';
import 'screens/create_event_screen.dart';
import 'models/event.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/events': (_) => const EventListScreen(),
        '/create': (_) => const CreateEventScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          final event = settings.arguments as Event;
          return MaterialPageRoute(builder: (_) => EventDetailScreen(event: event));
        }
        return null;
      },
    );
  }
}
