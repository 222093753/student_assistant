/**
 * Student Numbers: 222093753, 223005951, 221045356, 221032445, 223082890,
 * Student Names  : DM Skitla, KL Boisa, TD Mokoena, KD Hlokoane, SD Tshabalala,
 * Question: auth_wrapper.dart - Route Guard, Directs Users Based on Auth State & Role
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import 'login_view.dart';
import '../student/student_home_view.dart';
import '../admin/admin_dashboard_view.dart';

/// Listens to AuthViewModel and routes:
///  - Not logged in   →  LoginView
///  - Admin user      →  AdminDashboardView
///  - Student user    →  StudentHomeView
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, auth, _) {
        if (!auth.isLoggedIn) return const LoginView();
        if (auth.isAdmin)     return const AdminDashboardView();
        return const StudentHomeView();
      },
    );
  }
}
