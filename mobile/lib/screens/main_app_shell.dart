import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../config/theme.dart';
import 'home/patient_home_screen.dart';
import 'doctor/doctor_dashboard_screen.dart';
import 'profile/profile_screen.dart';

/// Main application shell with role-based bottom navigation
class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) => Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        final activeRole = authProvider.activeRole ?? UserRole.patient;

        if (user == null) {
          // Redirect to login if user is not authenticated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/auth/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Build navigation items based on active role
        final navItems = _buildNavigationItems(activeRole);
        final screens = _buildScreens(activeRole);

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: Colors.grey,
            items: navItems,
          ),
        );
      },
    );

  /// Build navigation items based on role
  List<BottomNavigationBarItem> _buildNavigationItems(UserRole role) {
    if (role == UserRole.doctor) {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Appointments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else {
      // Patient navigation
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Find Doctors',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Appointments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Health',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }
  }

  /// Build screens based on role
  List<Widget> _buildScreens(UserRole role) {
    if (role == UserRole.doctor) {
      return [
        const DoctorDashboardScreen(),
        _buildDoctorAppointmentsScreen(),
        _buildPlaceholderScreen('Chat - Coming Soon'),
        const ProfileScreen(),
      ];
    } else {
      // Patient screens
      return [
        const PatientHomeScreen(),
        _buildDoctorSearchScreen(),
        _buildPatientAppointmentsScreen(),
        _buildHealthProfileScreen(),
        const ProfileScreen(),
      ];
    }
  }

  /// Navigate to doctor search screen
  Widget _buildDoctorSearchScreen() => Builder(
      builder: (context) {
        // Navigate to doctor search on first build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_currentIndex == 1) {
            context.go('/doctors/search');
          }
        });
        return const Center(child: CircularProgressIndicator());
      },
    );

  /// Navigate to patient appointments screen
  Widget _buildPatientAppointmentsScreen() => Builder(
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_currentIndex == 2) {
            context.go('/appointments');
          }
        });
        return const Center(child: CircularProgressIndicator());
      },
    );

  /// Navigate to health profile screen
  Widget _buildHealthProfileScreen() => Builder(
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_currentIndex == 3) {
            context.go('/health-profile');
          }
        });
        return const Center(child: CircularProgressIndicator());
      },
    );

  /// Navigate to doctor appointments screen
  Widget _buildDoctorAppointmentsScreen() => Builder(
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_currentIndex == 1) {
            context.go('/doctor/appointments');
          }
        });
        return const Center(child: CircularProgressIndicator());
      },
    );

  /// Navigate to chat screen
  Widget _buildChatScreen() => Builder(
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_currentIndex == 2) {
            context.go('/chat');
          }
        });
        return const Center(child: CircularProgressIndicator());
      },
    );

  /// Placeholder screen for features not yet implemented
  Widget _buildPlaceholderScreen(String message) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
