import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialização da conexão com o Supabase
  await Supabase.initialize(
    url: 'https://whvfimazhqanykfypuve.supabase.co',
    anonKey: 'sb_publishable_ELGDWa_gzyiQQ3DWkWTooQ_XhQ49JUA',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Central de Chamados - P2',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      // Redireciona automaticamente conforme o estado da autenticação
      initialRoute: AuthService.isAuthenticated ? '/home' : '/login',
      onGenerateRoute: (settings) {
        // Proteção contra acesso direto à rota /home sem login
        if (settings.name == '/home' && !AuthService.isAuthenticated) {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }

        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          case '/home':
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          default:
            return MaterialPageRoute(
              builder: (_) => AuthService.isAuthenticated
                  ? const HomeScreen()
                  : const LoginScreen(),
            );
        }
      },
    );
  }
}
