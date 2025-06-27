class ApiUrl {
  static const api = 'http://localhost:8000/api';

  static const auth = '$api/auth';
  static const login = '$auth/login';
  static const logout = '$auth/logout';
  static const signup = '$auth/signup';
  static const getToken = '$auth/token';
  static const refreshToken = '$auth/refresh';

  static const user = '$api/user';
}
