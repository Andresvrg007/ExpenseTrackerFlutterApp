import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

// ViewModel para manejar autenticación (login, registro, logout)
class AuthViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Estado del usuario actual
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // Estados de carga
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  // Mensajes de error
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Inicializar: verificar si hay token guardado
  Future<void> initializeAuth() async {
    _setLoading(true);
    try {
      // Verificar si hay un token válido guardado
      final hasValidToken = await _apiService.hasValidToken();
      if (hasValidToken) {
        // Si hay token válido, obtener perfil del usuario
        await _loadUserProfile();
      }
    } catch (e) {
      _setError('Error al inicializar: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Realizar login
  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _setError('Email y contraseña son requeridos');
      return false;
    }

    _setLoading(true);
    _clearError();    try {
      // Llamar al endpoint de login
      final loginResponse = await _apiService.login(email, password);

      // Si el login es exitoso, solo marcar como logueado
      // Por ahora no cargaremos el perfil automáticamente
      _setLoggedIn(true);
      print('Login exitoso: $loginResponse'); // Para debug
      return true;
    } catch (e) {
      _setError('Error de login: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Realizar registro
  Future<bool> register(String name, String email, String password) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _setError('Todos los campos son requeridos');
      return false;
    }    if (password.length < 5) {
      _setError('La contraseña debe tener al menos 5 caracteres');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      // Llamar al endpoint de registro
      await _apiService.register(name, email, password);

      // Después del registro exitoso, hacer login automático
      return await login(email, password);
    } catch (e) {
      _setError('Error de registro: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Realizar logout
  Future<void> logout() async {
    _setLoading(true);
    try {
      // Llamar al endpoint de logout
      await _apiService.logout();

      // Limpiar estado local
      _currentUser = null;
      _setLoggedIn(false);
      _clearError();
    } catch (e) {
      // Incluso si falla el logout en el servidor, limpiar estado local
      _currentUser = null;
      _setLoggedIn(false);
      _setError('Error al cerrar sesión: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Cargar perfil del usuario desde la API
  Future<void> _loadUserProfile() async {
    try {
      _currentUser = await _apiService.getUserProfile();
      _setLoggedIn(true);
    } catch (e) {
      throw Exception('Error al cargar perfil: $e');
    }
  }

  // Métodos privados para manejar estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners(); // Notificar a la UI que el estado cambió
  }

  void _setLoggedIn(bool loggedIn) {
    _isLoggedIn = loggedIn;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Limpiar mensaje de error manualmente (útil para la UI)
  void clearError() {
    _clearError();
  }
}
