/**
 * Student Numbers: 222093753, 223005951, 221045356, 221032445, 223082890,
 * Student Names  : DM Skitla, KL Boisa, TD Mokoena, KD Hlokoane, SD Tshabalala,
 * Question: student_home_view.dart - Student Home Screen (Read Operation)
 *           Shows submitted applications, status summary, and navigation to form
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../models/sa_application.dart';
import '../../utils/app_theme.dart';
import 'application_form_view.dart';
import 'application_detail_view.dart';

class StudentHomeView extends StatefulWidget {
  const StudentHomeView({super.key});

  @override
  State<StudentHomeView> createState() => _StudentHomeViewState();
}

class _StudentHomeViewState extends State<StudentHomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationViewModel>().fetchMyApplications();
    });
  }

  Future<void> _refresh() =>
      context.read<ApplicationViewModel>().fetchMyApplications();

  void _goToForm() {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const ApplicationFormView())
    ).then((_) => _refresh());
  }

  void _goToDetail(SAApplication app) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => ApplicationDetailView(application: app))
    ).then((_) => _refresh());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final yes = await _confirmDialog(
                  context, 'Sign Out', 'Are you sure you want to sign out?');
              if (yes == true && context.mounted) {
                context.read<AuthViewModel>().signOut();
              }
            },
          ),
        ],
      ),
      body: Consumer<ApplicationViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && vm.myApplications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.errorMessage != null) {
            return _buildError(vm);
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(slivers: [
              SliverToBoxAdapter(child: _buildBanner(context)),
              SliverToBoxAdapter(child: _buildStats(vm)),
              if (vm.myApplications.isEmpty)
                SliverFillRemaining(child: _buildEmpty())
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _buildCard(vm.myApplications[i]),
                      childCount: vm.myApplications.length,
                    ),
                  ),
                ),
            ]),
          );
        },
      ),
      floatingActionButton: Consumer<ApplicationViewModel>(
        builder: (_, vm, __) => vm.hasApplication
            ? const SizedBox.shrink()
            : FloatingActionButton.extended(
                backgroundColor: AppTheme.primary,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Apply', style: TextStyle(color: Colors.white)),
                onPressed: _goToForm,
              ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context) {
    final email = context.read<AuthViewModel>().currentUserEmail ?? '';
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, Color(0xFF2A5298)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        const Icon(Icons.account_circle, color: Colors.white70, size: 48),
        const SizedBox(width: 16),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome back!',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            Text(email,
                style: const TextStyle(color: Colors.white, fontSize: 15,
                    fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis),
          ],
        )),
      ]),
    );
  }

  Widget _buildStats(ApplicationViewModel vm) {
    final pending  = vm.myApplications.where((a) => a.isPending).length;
    final approved = vm.myApplications.where((a) => a.isApproved).length;
    final rejected = vm.myApplications.where((a) => a.isRejected).length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        _statChip('Pending',  pending,  AppTheme.pending),
        const SizedBox(width: 8),
        _statChip('Approved', approved, AppTheme.success),
        const SizedBox(width: 8),
        _statChip('Rejected', rejected, AppTheme.danger),
      ]),
    );
  }

  Widget _statChip(String label, int count, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(children: [
        Text('$count',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 11, color: color)),
      ]),
    ),
  );

  Widget _buildCard(SAApplication app) {
    final color = app.isPending ? AppTheme.pending
        : app.isApproved ? AppTheme.success : AppTheme.danger;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _goToDetail(app),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Status + date row
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _badge(app.status.toUpperCase(), color),
              Text(
                '${app.createdAt.day}/${app.createdAt.month}/${app.createdAt.year}',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
            ]),
            const SizedBox(height: 12),
            Text(app.studentName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('No: ${app.studentNumber}',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
            const Divider(height: 20),
            _moduleRow('Module 1', app.module1Level, app.module1Name),
            if (app.hasSecondModule) ...[
              const SizedBox(height: 6),
              _moduleRow('Module 2', app.module2Level!, app.module2Name!),
            ],
            if (app.adminComment != null && app.adminComment!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  const Icon(Icons.comment_outlined, size: 14, color: AppTheme.textMuted),
                  const SizedBox(width: 6),
                  Expanded(child: Text(app.adminComment!,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted))),
                ]),
              ),
            const SizedBox(height: 8),
            const Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text('View Details',
                  style: TextStyle(color: AppTheme.primary, fontSize: 13,
                      fontWeight: FontWeight.w600)),
              Icon(Icons.chevron_right, color: AppTheme.primary, size: 18),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Text(text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
  );

  Widget _moduleRow(String tag, String level, String module) => Row(children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(tag, style: const TextStyle(fontSize: 11, color: AppTheme.primary,
          fontWeight: FontWeight.w600)),
    ),
    const SizedBox(width: 8),
    Expanded(child: Text('$level – $module',
        style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
  ]);

  Widget _buildEmpty() => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.assignment_outlined, size: 80,
          color: AppTheme.primary.withOpacity(0.3)),
      const SizedBox(height: 16),
      const Text('No Applications Yet',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text(
        'Tap the Apply button below to submit\nyour Student Assistant application.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
      ),
    ]),
  ));

  Widget _buildError(ApplicationViewModel vm) => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.error_outline, size: 48, color: AppTheme.danger),
      const SizedBox(height: 12),
      Text(vm.errorMessage ?? 'An error occurred'),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: _refresh, child: const Text('Retry')),
    ],
  ));

  Future<bool?> _confirmDialog(BuildContext ctx, String title, String msg) =>
      showDialog<bool>(
        context: ctx,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: Text(msg),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Confirm')),
          ],
        ),
      );
}
