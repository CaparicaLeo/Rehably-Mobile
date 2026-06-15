import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await _api.post('/login', body: {
      'email': email,
      'password': password,
    });
    final token = data['token'] as String;
    await _api.setToken(token);
    return data as Map<String, dynamic>;
  }

  Future<void> register(Map<String, dynamic> body) async {
    await _api.post('/register', body: body);
  }

  Future<void> logout() async {
    try {
      await _api.post('/logout');
    } finally {
      await _api.setToken(null);
    }
  }

  Future<Map<String, dynamic>> getUser() async {
    final data = await _api.get('/user');
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final data = await _api.post('/forgot-password', body: {'email': email});
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> resetPassword(Map<String, dynamic> body) async {
    final data = await _api.post('/reset-password', body: body);
    return data as Map<String, dynamic>;
  }
}
