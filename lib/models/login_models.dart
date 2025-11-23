import 'dart:convert';

// Modelo de requisição de login
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

// Modelo de permissão (authority)
class Permission {
  final String authority;

  Permission({required this.authority});

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(authority: json['authority'] ?? '');
  }

  Map<String, dynamic> toJson() => {'authority': authority};
}

// Modelo de permissão de módulo
class ModulePermission {
  final String modulo;
  final bool canView;
  final bool canCreate;
  final bool canUpdate;
  final bool canDelete;

  ModulePermission({
    required this.modulo,
    required this.canView,
    required this.canCreate,
    required this.canUpdate,
    required this.canDelete,
  });

  factory ModulePermission.fromJson(Map<String, dynamic> json) {
    return ModulePermission(
      modulo: json['modulo'] ?? '',
      canView: json['can_view'] ?? false,
      canCreate: json['can_create'] ?? false,
      canUpdate: json['can_update'] ?? false,
      canDelete: json['can_delete'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'modulo': modulo,
    'can_view': canView,
    'can_create': canCreate,
    'can_update': canUpdate,
    'can_delete': canDelete,
  };
}

// Modelo de resposta de login
class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final List<Permission> permissoes;
  final List<ModulePermission> permissoesModulos;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.permissoes,
    required this.permissoesModulos,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      permissoes:
          (json['permissoes'] as List<dynamic>?)
              ?.map((e) => Permission.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      permissoesModulos:
          (json['permissoes_modulos'] as List<dynamic>?)
              ?.map((e) => ModulePermission.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'permissoes': permissoes.map((e) => e.toJson()).toList(),
    'permissoes_modulos': permissoesModulos.map((e) => e.toJson()).toList(),
  };

  // Getter para compatibilidade com código existente
  String get token => accessToken;

  // Criar um objeto user básico a partir do email do token
  Map<String, dynamic> get user {
    final email = _extractEmailFromToken();
    return {
      'email': email,
      'nome': email.isNotEmpty ? email.split('@')[0] : 'Usuário',
    };
  }

  String _extractEmailFromToken() {
    // Decodificar JWT para extrair email
    try {
      final parts = accessToken.split('.');
      if (parts.length != 3) return '';

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> payloadMap = json.decode(decoded);

      return payloadMap['sub'] ?? '';
    } catch (e) {
      return '';
    }
  }

  // Métodos auxiliares para verificar permissões
  bool hasAuthority(String authority) {
    return permissoes.any((p) => p.authority == authority);
  }

  bool hasRole(String role) {
    return permissoes.any(
      (p) => p.authority == 'ROLE_$role' || p.authority == role,
    );
  }

  ModulePermission? getModulePermission(String moduleName) {
    try {
      return permissoesModulos.firstWhere(
        (p) => p.modulo.toUpperCase() == moduleName.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  bool canAccessModule(String moduleName, {String action = 'view'}) {
    final modulePermission = getModulePermission(moduleName);
    if (modulePermission == null) return false;

    switch (action.toLowerCase()) {
      case 'view':
        return modulePermission.canView;
      case 'create':
        return modulePermission.canCreate;
      case 'update':
        return modulePermission.canUpdate;
      case 'delete':
        return modulePermission.canDelete;
      default:
        return false;
    }
  }
}
