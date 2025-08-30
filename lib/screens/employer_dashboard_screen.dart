import 'package:flutter/material.dart';
import 'employer/employer_home_screen.dart';
import 'employer/employer_my_jobs_screen.dart';
import 'employer/employer_applications_screen.dart';
import 'employer/employer_profile_screen.dart';
import '../widgets/navigation/employer_bottom_nav.dart';

class EmployerDashboardScreen extends StatefulWidget {
  const EmployerDashboardScreen({super.key});

  @override
  State<EmployerDashboardScreen> createState() => _EmployerDashboardScreenState();
}

class _EmployerDashboardScreenState extends State<EmployerDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    EmployerHomeScreen(),
    EmployerMyJobsScreen(),
    EmployerApplicationsScreen(),
    EmployerProfileScreen(),
  ];

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: EmployerBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
