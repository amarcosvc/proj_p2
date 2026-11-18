import 'package:supabase_flutter/supabase_flutter.dart';

// Serviço responsável pela autenticação (Cadastro, Login, Logout e Sessão)
class AuthService {
  static final _supabase = Supabase.instance.client;

  static User? get currentUser => _supabase.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;

  // Registra um novo usuário no Supabase Auth
  static Future<String?> register(String name, String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name.trim()},
      );

      if (response.user == null) {
        return 'Não foi possível concluir o cadastro.';
      }
      return null;
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('already registered')) {
        return 'Este e-mail já está cadastrado.';
      }
      return e.message;
    } catch (_) {
      return 'Erro de conexão ao realizar cadastro.';
    }
  }

  // Autentica usuário com e-mail e senha
  static Future<String?> login(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on AuthException {
      return 'E-mail ou senha inválidos.';
    } catch (_) {
      return 'Erro de conexão ao realizar login.';
    }
  }

  // Encerra a sessão atual
  static Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}
