import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/health_profile_model.dart';
import '../providers/auth_provider.dart';
import '../screens/appointments/appointment_detail_screen.dart';
import '../screens/appointments/appointment_list_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/registration_form_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/auth/verification_pending_screen.dart';
import '../screens/doctor/doctor_appointment_detail_screen.dart';
import '../screens/doctor/doctor_appointment_list_screen.dart';
import '../screens/doctor/doctor_dashboard_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_users_list_screen.dart';
import '../screens/admin/admin_user_status_list_screen.dart';
import '../screens/admin/admin_user_detail_screen.dart';
import '../screens/doctor_search/doctor_detail_screen.dart';
import '../screens/doctor_search/doctor_search_screen.dart';
import '../screens/health_profile/allergy_form_screen.dart';
import '../screens/health_profile/chronic_condition_form_screen.dart';
import '../screens/health_profile/health_profile_edit_screen.dart';
import '../screens/health_profile/health_profile_view_screen.dart';
import '../screens/main_app_shell.dart';
import '../screens/profile/profile_screen.dart';

/// Application router configuration
class AppRouter {
  AppRouter._();

  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Splash/Loading screen
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Authentication routes
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/role-selection',
        name: 'role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/auth/registration',
        name: 'registration',
        builder: (context, state) => const RegistrationFormScreen(),
      ),
      GoRoute(
        path: '/auth/verification-pending',
        name: 'verification-pending',
        builder: (context, state) => const VerificationPendingScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      
      // Main app routes
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const MainAppShell(),
      ),
      
      // Profile routes
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      
      // Health Profile routes
      GoRoute(
        path: '/health-profile',
        name: 'health-profile',
        builder: (context, state) => const HealthProfileViewScreen(),
      ),
      GoRoute(
        path: '/health-profile/edit',
        name: 'health-profile-edit',
        builder: (context, state) {
          final profile = state.extra as HealthProfile?;
          return HealthProfileEditScreen(profile: profile);
        },
      ),
      GoRoute(
        path: '/health-profile/chronic-condition/add',
        name: 'chronic-condition-add',
        builder: (context, state) => const ChronicConditionFormScreen(),
      ),
      GoRoute(
        path: '/health-profile/chronic-condition/edit',
        name: 'chronic-condition-edit',
        builder: (context, state) {
          final condition = state.extra as Map<String, dynamic>?;
          return ChronicConditionFormScreen(
            existingCondition: condition?['name'] as String?,
            conditionIndex: condition?['index'] as int?,
          );
        },
      ),
      GoRoute(
        path: '/health-profile/allergy/add',
        name: 'allergy-add',
        builder: (context, state) => const AllergyFormScreen(),
      ),
      GoRoute(
        path: '/health-profile/allergy/edit',
        name: 'allergy-edit',
        builder: (context, state) {
          final allergy = state.extra as Map<String, dynamic>?;
          return AllergyFormScreen(existingAllergy: allergy);
        },
      ),
      
      // Doctor Search routes
      GoRoute(
        path: '/doctors/search',
        name: 'doctor-search',
        builder: (context, state) => const DoctorSearchScreen(),
      ),
      GoRoute(
        path: '/doctors/:id',
        name: 'doctor-detail',
        builder: (context, state) {
          final doctorId = state.pathParameters['id']!;
          return DoctorDetailScreen(doctorId: doctorId);
        },
      ),
      
      // Appointment routes
      GoRoute(
        path: '/appointments',
        name: 'appointments',
        builder: (context, state) => const AppointmentListScreen(),
      ),
      GoRoute(
        path: '/appointments/:id',
        name: 'appointment-detail',
        builder: (context, state) {
          final appointmentId = state.pathParameters['id']!;
          return AppointmentDetailScreen(appointmentId: appointmentId);
        },
      ),

      // Doctor routes
      GoRoute(
        path: '/doctor/dashboard',
        name: 'doctor-dashboard',
        builder: (context, state) => const DoctorDashboardScreen(),
      ),
      GoRoute(
        path: '/doctor/appointments',
        name: 'doctor-appointments',
        builder: (context, state) => const DoctorAppointmentListScreen(),
      ),
      GoRoute(
        path: '/doctor/appointments/:id',
        name: 'doctor-appointment-detail',
        builder: (context, state) {
          final appointmentId = state.pathParameters['id']!;
          return DoctorAppointmentDetailScreen(appointmentId: appointmentId);
        },
      ),

      // Admin routes
      GoRoute(
        path: '/admin',
        name: 'admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/:role/select-status',
        name: 'admin-select-status',
        builder: (context, state) {
          final role = state.pathParameters['role']!;
          final roleTitle = role == 'patient' ? 'Patients' : 'Doctors';
          return AdminUsersListScreen(
            userRole: role,
            title: 'Review $roleTitle',
          );
        },
      ),
      GoRoute(
        path: '/admin/:role/:status',
        name: 'admin-user-list',
        builder: (context, state) {
          final role = state.pathParameters['role']!;
          final status = state.pathParameters['status']!;
          final roleTitle = role == 'patient' ? 'Patients' : 'Doctors';
          final statusTitle = status[0].toUpperCase() + status.substring(1);
          return AdminUserStatusListScreen(
            userRole: role,
            status: status,
            title: '$statusTitle $roleTitle',
          );
        },
      ),
      GoRoute(
        path: '/admin/user/:userId',
        name: 'admin-user-detail',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          final status = state.uri.queryParameters['status'] ?? 'pending';
          return AdminUserDetailScreen(userId: userId, userStatus: status);
        },
      ),
    ],
    
    // Error handler
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
    
    // Redirect logic for authentication
    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();
      final isAuthenticated = authProvider.isAuthenticated;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      
      // If not authenticated and trying to access protected routes
      if (!isAuthenticated && !isAuthRoute && state.matchedLocation != '/') {
        return '/auth/login';
      }
      
      // If authenticated and trying to access auth routes
      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }
      
      return null;
    },
  );

  static GoRouter get router => _router;
}

// Placeholder screens - replace with actual implementations
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Auto-navigate after checking auth state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated) {
        context.go('/home');
      } else {
        context.go('/auth/login');
      }
    });

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading Viatra Health...'),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: const Center(
        child: Text('Forgot Password Screen - TODO: Implement'),
      ),
    );
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(
        child: Text('Settings Screen - TODO: Implement'),
      ),
    );
}

class ErrorScreen extends StatelessWidget {
  
  const ErrorScreen({super.key, this.error});
  final Object? error;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text('Something went wrong'),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
}
