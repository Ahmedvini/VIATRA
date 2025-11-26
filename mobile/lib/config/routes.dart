import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/auth/registration_form_screen.dart';
import '../screens/auth/verification_pending_screen.dart';
import '../screens/health_profile/health_profile_view_screen.dart';
import '../screens/health_profile/health_profile_edit_screen.dart';
import '../screens/health_profile/chronic_condition_form_screen.dart';
import '../screens/health_profile/allergy_form_screen.dart';
import '../screens/doctor_search/doctor_search_screen.dart';
import '../screens/doctor_search/doctor_detail_screen.dart';
import '../screens/appointments/appointment_list_screen.dart';
import '../screens/appointments/appointment_detail_screen.dart';

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
        builder: (context, state) => const HomeScreen(),
      ),
      
      // Profile routes
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      
      // Settings routes
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
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
          final profile = state.extra;
          return HealthProfileEditScreen(
            profile: profile != null ? profile as dynamic : null,
          );
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: const Center(
        child: Text('Forgot Password Screen - TODO: Implement'),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viatra Health'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
            tooltip: 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Viatra Health',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your healthcare companion',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Quick actions
            Text(
              'Quick Actions',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Action cards grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildActionCard(
                  context,
                  icon: Icons.search,
                  title: 'Find Doctors',
                  subtitle: 'Search & book',
                  color: Colors.blue,
                  onTap: () => context.push('/doctors/search'),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.health_and_safety,
                  title: 'Health Profile',
                  subtitle: 'Manage your health',
                  color: Colors.green,
                  onTap: () => context.push('/health-profile'),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.calendar_today,
                  title: 'Appointments',
                  subtitle: 'View & schedule',
                  color: Colors.orange,
                  onTap: () => context.push('/appointments'),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.medical_services,
                  title: 'Prescriptions',
                  subtitle: 'View & refill',
                  color: Colors.purple,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(
        child: Text('Profile Screen - TODO: Implement'),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(
        child: Text('Settings Screen - TODO: Implement'),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final Object? error;
  
  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
}
