import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/admin_dashboard.dart';
import '../screens/dashboard/collector_dashboard.dart';
import '../screens/dashboard/citizen_dashboard.dart';
import '../screens/dustbin/dustbin_details_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/roles',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/login/:role',
        builder: (context, state) {
          final roleString = state.pathParameters['role'] ?? 'citizen';
          final role = UserRole.values.firstWhere(
            (e) => e.name == roleString,
            orElse: () => UserRole.citizen,
          );
          return LoginScreen(role: role);
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/collector',
        builder: (context, state) => const CollectorDashboard(),
      ),
      GoRoute(
        path: '/citizen',
        builder: (context, state) => const CitizenDashboard(),
      ),
      GoRoute(
        path: '/dustbin/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return DustbinDetailsScreen(dustbinId: id);
        },
      ),
    ],
  );
});
