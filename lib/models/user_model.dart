enum UserRole {
  admin,
  collector,
  citizen;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Campus Admin';
      case UserRole.collector:
        return 'Waste Collector';
      case UserRole.citizen:
        return 'Citizen / Student';
    }
  }

  static UserRole fromString(String roleStr) {
    return UserRole.values.firstWhere(
      (e) => e.name == roleStr.toLowerCase(),
      orElse: () => UserRole.citizen,
    );
  }
}

class UserModel {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? assignedArea;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.assignedArea,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: UserRole.fromString(json['role'] as String),
      assignedArea: json['assignedArea'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'assignedArea': assignedArea,
      'avatarUrl': avatarUrl,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? assignedArea,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      assignedArea: assignedArea ?? this.assignedArea,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
