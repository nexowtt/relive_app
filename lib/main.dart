import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'app_auth_provider.dart';
import '/welcome_screen.dart';
import '/login_screen.dart';
import '/home_screen.dart';
import 'services/memory_service.dart'; 
import '/screens/add_edit_memory_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("✅ Firebase успешно инициализирован");
  } catch (e) {
    debugPrint("❌ Ошибка инициализации Firebase: $e");
  }

  runApp(const ReLiveApp());
}

class ReLiveApp extends StatelessWidget {
  const ReLiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
         Provider<MemoryService>(create: (_) => MemoryService()), 
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ReLive',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: const Color(0xFFF8F9FF),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: Color(0xFF2D2B3A)),
          ),
        ),
        home: const AuthWrapper(),
        routes: {
          '/welcome': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/add_memory': (context) => AddEditMemoryScreen(onSave: () {},
          )
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    
    if (authProvider.user != null) {
      return const HomeScreen();
    } else {
      return const WelcomeScreen();
    }
  }
}