import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppAuthProvider with ChangeNotifier {
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  AppAuthProvider() {
    // Слушаем изменения состояния аутентификации
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signUp(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      debugPrint('📝 Регистрация: $email');
      
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      debugPrint('✅ Успешная регистрация: ${credential.user?.email}');
      
      _errorMessage = null;
      
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Ошибка регистрации: ${e.code} - ${e.message}');
      _errorMessage = _getErrorMessage(e);
    } catch (e) {
      debugPrint('❌ Неизвестная ошибка: $e');
      _errorMessage = 'Произошла ошибка: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      debugPrint('🔐 Попытка входа: $email');
      
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      debugPrint('✅ Успешный вход: ${credential.user?.email}');
      
      _errorMessage = null;
      
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Ошибка входа: ${e.code} - ${e.message}');
      _errorMessage = _getErrorMessage(e);
    } catch (e) {
      debugPrint('❌ Неизвестная ошибка: $e');
      _errorMessage = 'Произошла ошибка: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Ошибка при выходе: $e';
    }
    notifyListeners();
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Этот email уже зарегистрирован';
      case 'invalid-email':
        return 'Неверный формат email';
      case 'weak-password':
        return 'Пароль слишком слабый (минимум 6 символов)';
      case 'user-not-found':
        return 'Пользователь не найден';
      case 'wrong-password':
        return 'Неверный пароль';
      case 'user-disabled':
        return 'Аккаунт заблокирован';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуйте позже';
      case 'network-request-failed':
        return 'Ошибка сети. Проверьте подключение';
      default:
        return 'Произошла ошибка: ${e.message}';
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}