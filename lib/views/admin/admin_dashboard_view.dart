/**
 * Student Numbers: 222093753, 223005951, 221045356, 221032445, 223082890,
 * Student Names  : DM Skitla, KL Boisa, TD Mokoena, KD Hlokoane, SD Tshabalala,
 * Question: admin_dashboard_view.dart - Admin Portal (Read / Update / Delete)
 *           Admin can view ALL applications, approve/reject, add comments, delete
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../models/sa_application.dart';
import '../../utils/app_theme.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  String _filter = 'all';

  final List<Map<String, String>> _filters = [
    {'v': 'all',      'l': 'All'},
    {'v': 'pending',  'l': 'Pending'},
    {'v': 'approved', 'l': 'Approved'},
    {'v': 'rejected', 'l': 'Rejected'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationViewModel>().fetchAllApplications();
    });
  }

  void _applyFilter(String f) {
    setState(() => _filter = f);
    context.read<ApplicationViewModel>()
        .fetchAllApplications(statusFilter: f);
  }

  Future<void> _refresh() => context
      .read<ApplicationViewModel>()
      .fetchAllApplications(statusFilter: _filter);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final yes = await _confirmDialog(context,
                  'Sign Out', 'Are you sure you want to sign out?');
              if (yes == true && context.mounted) {
                context.read<AuthViewModel>().signOut();
              }
            },
          ),
        ],
      ),
      body: Consumer<ApplicationViewModel>(
        builder: (context, vm, _) => Column(children: [
          // ── Stats banner ────────────────────────────────────────────────
          _buildStatsBanner(vm),

          // ── Filter row ──────────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(children: _filters.map((f) {
              final sel = _filter == f['v'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(f['l']!),
                  selected: sel,
                  selectedColor: AppTheme.primary,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: sel ? Colors.white : AppTheme.textDark,
                    fontWeight:
                        sel ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) => _applyFilter(f['v']!),
                ),
              );
            }).toList()),
          ),

          // ── Applications list ────────────────────────────────────────────
          Expanded(
            child: vm.isLoading && vm.allApplications.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : vm.allApplications.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: vm.allApplications.length,
                          itemBuilder: (_, i) =>
                              _buildCard(context, vm.allApplications[i]),
                        ),
                      ),
          ),
        ]),
      ),
    );
  }

  // ── Stats Banner ──────────────────────────────────────────────────────────
  Widget _buildStatsBanner(ApplicationViewModel vm) {
    // Always read from unfiltered total for the banner
    final all      = vm.allApplications;
    final total    = all.length;
    final pending  = all.where((a) => a.isPending).length;
    final approved = all.where((a) => a.isApproved).length;
    final rejected = all.where((a) => a.isRejected).length;

    return Container(
      color: AppTheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        _stat('Total',    total,    Colors.white),
        _stat('Pending',  pending,  AppTheme.accent),
        _stat('Approved', approved, Colors.greenAccent),
        _stat('Rejected', rejected, Colors.redAccent),
      ]),
    );
  }

  Widget _stat(String label, int count, Color color) => Expanded(
    child: Column(children: [
      Text('$count',
          style: TextStyle(color: color, fontSize: 22,
              fontWeight: FontWeight.bold)),
      Text(label,
          style: const TextStyle(color: Colors.white70, fontSize: 11)),
    ]),
  );

  // ── Application Card ──────────────────────────────────────────────────────
  Widget _buildCard(BuildContext context, SAApplication app) {
    final color = app.isPending  ? AppTheme.pending
                : app.isApproved ? AppTheme.success
                : AppTheme.danger;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Text(
            app.studentName.isNotEmpty
                ? app.studentName[0].toUpperCase()
                : '?',
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(app.studentName,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No: ${app.studentNumber}  |  Year ${app.yearOfStudy}',
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                app.status.toUpperCase(),
                style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                _infoRow('Module 1',
                    '${app.module1Level} – ${app.module1Name}'),
                if (app.hasSecondModule)
                  _infoRow('Module 2',
                      '${app.module2Level} – ${app.module2Name}'),
                _infoRow('Meets Requirements',
                    app.meetsRequirements ? 'Yes' : 'No'),
                _infoRow('Document',
                    app.documentUrl != null ? 'Uploaded ✓' : 'Not uploaded'),
                _infoRow('Submitted', _fmt(app.createdAt)),
                if (app.adminComment != null &&
                    app.adminComment!.isNotEmpty)
                  _infoRow('Admin Comment', app.adminComment!),

                const SizedBox(height: 16),

                // ── Approve / Reject (only when pending) ─────────────────
                if (app.isPending)
                  Row(children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.success),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Approve'),
                        onPressed: () =>
                            _showStatusDialog(context, app, 'approved'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.danger),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Reject'),
                        onPressed: () =>
                            _showStatusDialog(context, app, 'rejected'),
                      ),
                    ),
                  ]),

                if (app.isPending) const SizedBox(height: 8),

                // ── Remove (always visible to admin) ─────────────────────
                OutlinedButton.icon(
                  icon: const Icon(Icons.delete_outline,
                      size: 16, color: AppTheme.danger),
                  label: const Text('Remove Application',
                      style: TextStyle(color: AppTheme.danger)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.danger),
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _confirmDelete(context, app),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: 148,
        child: Text(label,
            style: const TextStyle(
                color: AppTheme.textMuted, fontSize: 13)),
      ),
      Expanded(child: Text(value,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500))),
    ]),
  );

  Widget _buildEmpty() => const Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.inbox_outlined, size: 64, color: AppTheme.textMuted),
      SizedBox(height: 12),
      Text('No applications found',
          style: TextStyle(fontSize: 16, color: AppTheme.textMuted)),
    ]),
  );

  // ── Approve / Reject Dialog ───────────────────────────────────────────────
  Future<void> _showStatusDialog(
      BuildContext context, SAApplication app, String newStatus) async {
    final commentCtrl = TextEditingController();
    final action      = newStatus == 'approved' ? 'Approve' : 'Reject';

    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$action Application'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Are you sure you want to $action '
              '${app.studentName}\'s application?'),
          const SizedBox(height: 12),
          TextField(
            controller: commentCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Comment (optional)',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == 'approved'
                  ? AppTheme.success
                  : AppTheme.danger,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    );

    if (yes == true && context.mounted) {
      final vm = context.read<ApplicationViewModel>();
      final ok = await vm.updateStatus(
        id:           app.id,
        status:       newStatus,
        adminComment: commentCtrl.text.trim().isNotEmpty
            ? commentCtrl.text.trim()
            : null,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok
              ? 'Application ${newStatus}!'
              : (vm.errorMessage ?? 'Failed to update.')),
          backgroundColor:
              ok ? AppTheme.success : AppTheme.danger,
        ));
      }
    }
  }

  // ── Delete Dialog ─────────────────────────────────────────────────────────
  Future<void> _confirmDelete(
      BuildContext context, SAApplication app) async {
    final yes = await _confirmDialog(
      context,
      'Remove Application',
      'Remove ${app.studentName}\'s application permanently?\n'
          'This cannot be undone.',
    );

    if (yes == true && context.mounted) {
      final vm = context.read<ApplicationViewModel>();
      final ok = await vm.deleteApplication(app.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok
              ? 'Application removed.'
              : (vm.errorMessage ?? 'Failed to remove.')),
          backgroundColor:
              ok ? AppTheme.success : AppTheme.danger,
        ));
      }
    }
  }

  Future<bool?> _confirmDialog(
      BuildContext context, String title, String msg) =>
      showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: Text(msg),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirm')),
          ],
        ),
      );

  String _fmt(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';
}
