class ApiConfig {
  // Base URL da API
  static const String baseUrl = 'https://agenda-apisecvirtual.qai0d1.easypanel.host';
  
  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  
  // Timeout para requisições
  static const Duration timeout = Duration(seconds: 30);
  
  // Headers padrão
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Headers com autenticação
  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}
