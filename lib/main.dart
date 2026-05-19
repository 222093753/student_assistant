/**
 * Student Numbers: 222093753, 223005951, 221045356, 221032445, 223082890,
 * Student Names  : DM Skitla, KL Boisa, TD Mokoena, KD Hlokoane, SD Tshabalala,
 * Question: main.dart - App Entry Point, Supabase Initialization, Provider Setup
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/application_viewmodel.dart';
import 'views/auth/auth_wrapper.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Initialize Supabase ──────────────────────────────────────────────────
  // STEP: Replace these two values with your actual Supabase credentials.
  // Find them at: Supabase Dashboard → Project Settings → API
  await Supabase.initialize(
    url: 'https://bqsdijtncktoqnlcezss.supabase.co',        // e.g. https://abcdefgh.supabase.co
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJxc2RpanRuY2t0b3FubGNlenNzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg5OTY4MDcsImV4cCI6MjA5NDU3MjgwN30.j5rZN8XLun0MbktmfTr7VpztRg7HHwvPrbNfdSNELmo',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ApplicationViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SA Application System',
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}
