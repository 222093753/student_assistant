/**
 * Student Numbers: 222093753, 223005951, 221045356, 221032445, 223082890,
 * Student Names  : DM Skitla, KL Boisa, TD Mokoena, KD Hlokoane, SD Tshabalala,
 * Question: application_detail_view.dart - Application Details Screen
 *           Implements: Read, Update (edit), Delete operations for student
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/application_viewmodel.dart';
import '../../models/sa_application.dart';
import '../../utils/app_theme.dart';
import 'application_form_view.dart';

class ApplicationDetailView extends StatelessWidget {
  final SAApplication application;

  const ApplicationDetailView({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final color  = application.isPending  ? AppTheme.pending
                 : application.isApproved ? AppTheme.success
                 : AppTheme.danger;
    final icon   = application.isPending  ? Icons.hourglass_empty
                 : application.isApproved ? Icons.check_circle
                 : Icons.cancel;
    final msg    = application.isPending  ? 'Your application is under review.'
                 : application.isApproved ? 'Congratulations! You have been approved.'
                 : 'Unfortunately your application was rejected.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
        actions: [
          if (application.isPending) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) =>
                    ApplicationFormView(application: application)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

          // ── Status Banner ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.35)),
            ),
            child: Row(children: [
              Icon(icon, color: color, size: 48),
              const SizedBox(width: 16),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status: ${application.status.toUpperCase()}',
                      style: TextStyle(color: color,
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(msg, style: TextStyle(color: color.withOpacity(0.85),
                      fontSize: 13)),
                ],
              )),
            ]),
          ),

          const SizedBox(height: 20),

          // ── Personal Info ──────────────────────────────────────────────
          _card('Personal Information', Icons.person_outline, [
            _row('Full Name',      application.studentName),
            _row('Student Number', application.studentNumber),
            _row('Year of Study',  'Year ${application.yearOfStudy}'),
          ]),
          const SizedBox(height: 14),

          // ── Module 1 ───────────────────────────────────────────────────
          _card('Module Application 1', Icons.book_outlined, [
            _row('Academic Level', application.module1Level),
            _row('Module',         application.module1Name),
          ]),

          // ── Module 2 ───────────────────────────────────────────────────
          if (application.hasSecondModule) ...[
            const SizedBox(height: 14),
            _card('Module Application 2', Icons.book_outlined, [
              _row('Academic Level', application.module2Level!),
              _row('Module',         application.module2Name!),
            ]),
          ],
          const SizedBox(height: 14),

          // ── Eligibility & Docs ─────────────────────────────────────────
          _card('Eligibility & Documentation', Icons.verified_outlined, [
            _row('Meets Requirements',
                application.meetsRequirements ? 'Yes ✓' : 'No ✗'),
            _row('Supporting Document',
                application.documentUrl != null
                    ? 'Uploaded ✓'
                    : 'Not uploaded'),
          ]),

          // ── Admin Comment ──────────────────────────────────────────────
          if (application.adminComment != null &&
              application.adminComment!.isNotEmpty) ...[
            const SizedBox(height: 14),
            _card('Admin Comment', Icons.comment_outlined, [
              Text(application.adminComment!,
                  style: const TextStyle(fontSize: 14,
                      color: AppTheme.textDark)),
            ]),
          ],
          const SizedBox(height: 14),

          // ── Timestamps ─────────────────────────────────────────────────
          _card('Submission Info', Icons.schedule_outlined, [
            _row('Submitted',     _fmt(application.createdAt)),
            _row('Last Updated',  _fmt(application.updatedAt)),
          ]),

          const SizedBox(height: 24),

          // ── Action Buttons (only when pending) ─────────────────────────
          if (application.isPending) ...[
            OutlinedButton.icon(
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Application'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) =>
                    ApplicationFormView(application: application)),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete Application'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.danger,
                side: const BorderSide(color: AppTheme.danger),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _confirmDelete(context),
            ),
            const SizedBox(height: 24),
          ],
        ]),
      ),
    );
  }

  Widget _card(String title, IconData icon, List<Widget> children) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: AppTheme.primary, size: 18),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 14,
              fontWeight: FontWeight.bold, color: AppTheme.primary)),
        ]),
        const Divider(height: 16),
        ...children,
      ]),
    ),
  );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: 145,
        child: Text(label,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
      ),
      Expanded(child: Text(value,
          style: const TextStyle(fontSize: 13,
              fontWeight: FontWeight.w500, color: AppTheme.textDark))),
    ]),
  );

  String _fmt(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}  ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';

  Future<void> _confirmDelete(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Application'),
        content: const Text(
            'Are you sure you want to delete this application?\n'
            'This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.danger),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );

    if (yes == true && context.mounted) {
      final vm = context.read<ApplicationViewModel>();
      final ok = await vm.deleteApplication(application.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? 'Application deleted.' :
              (vm.errorMessage ?? 'Failed to delete.')),
          backgroundColor: ok ? AppTheme.success : AppTheme.danger,
        ));
        if (ok) Navigator.pop(context);
      }
    }
  }
}
