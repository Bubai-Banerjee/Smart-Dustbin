import 'dart:async';
import '../models/user_model.dart';

class AuthService {
  // Simulate active session
  UserModel? _currentUser;
  
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Mock list of registered users
  final List<UserModel> _mockUsers = [
    UserModel(
      id: 'usr-admin-01',
      email: 'admin@greentech.edu',
      name: 'Dr. Sarah Jenkins',
      role: UserRole.admin,
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    ),
    UserModel(
      id: 'usr-collector-01',
      email: 'collector@greentech.edu',
      name: 'Rahul Das',
      role: UserRole.collector,
      assignedArea: 'ICT & Engineering Buildings',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    ),
    UserModel(
      id: 'usr-citizen-01',
      email: 'citizen@greentech.edu',
      name: 'Amit Sharma',
      role: UserRole.citizen,
      avatarUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150',
    ),
  ];

  // Log in with Email & Password
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
    required UserRole expectedRole,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1500)); // Dynamic network latency

    final normalizedEmail = email.trim().toLowerCase();
    
    // Validate dummy logic
    final user = _mockUsers.firstWhere(
      (u) => u.email == normalizedEmail,
      orElse: () => throw Exception('User not found. Try admin@greentech.edu, collector@greentech.edu, or citizen@greentech.edu.'),
    );

    // Simple password check (any 6+ char password passes, or role-based check)
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters.');
    }

    if (user.role != expectedRole) {
      throw Exception('Authorized role mismatch. Select the correct dashboard.');
    }

    _currentUser = user;
    return user;
  }

  // Simulate Biometric login
  Future<UserModel> loginWithBiometrics(UserRole expectedRole) async {
    await Future.delayed(const Duration(milliseconds: 2000)); // Biometric scan duration

    final user = _mockUsers.firstWhere(
      (u) => u.role == expectedRole,
      orElse: () => throw Exception('No credentials configured for this role.'),
    );

    _currentUser = user;
    return user;
  }

  // Sign Out
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = null;
  }
}
