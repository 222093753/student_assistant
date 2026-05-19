/**
  * Student Numbers: 222093753, 223005951, 221045356, 221032445, 223082890,
 * Student Names  : DM Skitla, KL Boisa, TD Mokoena, KD Hlokoane, SD Tshabalala,
 * Question: application_form_view.dart - SA Application Form (Create & Update Operation)
 *           Demonstrates: Form validation, controlled inputs, file upload, Provider
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../../viewmodels/application_viewmodel.dart';
import '../../models/sa_application.dart';
import '../../utils/app_theme.dart';

class ApplicationFormView extends StatefulWidget {
  /// Pass an existing application to enable EDIT mode.
  final SAApplication? application;

  const ApplicationFormView({super.key, this.application});

  bool get isEditMode => application != null;

  @override
  State<ApplicationFormView> createState() => _ApplicationFormViewState();
}

class _ApplicationFormViewState extends State<ApplicationFormView> {
  final _formKey = GlobalKey<FormState>();

  // Personal info
  final _nameCtrl   = TextEditingController();
  final _numberCtrl = TextEditingController();

  // Dropdowns
  int?    _year;
  String? _m1Level;
  String? _m1Name;
  String? _m2Level;
  String? _m2Name;
  bool    _addM2            = false;
  bool    _meetsRequirements = false;
  File?   _pickedFile;
  String? _existingDocUrl;

  // ── Reference data ───────────────────────────────────────────────────────
  final List<int>    _years  = [1, 2, 3];
  final List<String> _levels = ['1st Year', '2nd Year', '3rd Year'];

  final Map<String, List<String>> _modules = {
    '1st Year': [
      'Introduction to Programming',
      'Computer Literacy',
      'Mathematics for IT',
      'Business Communication',
    ],
    '2nd Year': [
      'Object-Oriented Programming',
      'Database Management',
      'Systems Analysis',
      'Networking Fundamentals',
    ],
    '3rd Year': [
      'Technical Programming III',
      'Software Engineering',
      'Project Management',
      'Mobile Application Development',
    ],
  };

  @override
  void initState() {
    super.initState();
    if (widget.isEditMode) {
      final a = widget.application!;
      _nameCtrl.text   = a.studentName;
      _numberCtrl.text = a.studentNumber;
      _year            = a.yearOfStudy;
      _m1Level         = a.module1Level;
      _m1Name          = a.module1Name;
      _m2Level         = a.module2Level;
      _m2Name          = a.module2Name;
      _meetsRequirements = a.meetsRequirements;
      _addM2           = a.hasSecondModule;
      _existingDocUrl  = a.documentUrl;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    super.dispose();
  }

  // ── Pick file ─────────────────────────────────────────────────────────────
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _pickedFile = File(result.files.single.path!));
    }
  }

  // ── Submit ─────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_meetsRequirements) {
      _showSnack('You must confirm that you meet the minimum requirements.',
          isError: true);
      return;
    }

    if (_addM2 && (_m2Level == null || _m2Name == null)) {
      _showSnack('Please select both level and module for Module 2.',
          isError: true);
      return;
    }

    final vm = context.read<ApplicationViewModel>();
    bool ok;

    if (widget.isEditMode) {
      ok = await vm.updateApplication(
        id:                widget.application!.id,
        studentName:       _nameCtrl.text.trim(),
        studentNumber:     _numberCtrl.text.trim(),
        yearOfStudy:       _year!,
        module1Level:      _m1Level!,
        module1Name:       _m1Name!,
        module2Level:      _addM2 ? _m2Level : null,
        module2Name:       _addM2 ? _m2Name  : null,
        meetsRequirements: _meetsRequirements,
        newDocumentFile:   _pickedFile,
      );
    } else {
      ok = await vm.submitApplication(
        studentName:       _nameCtrl.text.trim(),
        studentNumber:     _numberCtrl.text.trim(),
        yearOfStudy:       _year!,
        module1Level:      _m1Level!,
        module1Name:       _m1Name!,
        module2Level:      _addM2 ? _m2Level : null,
        module2Name:       _addM2 ? _m2Name  : null,
        meetsRequirements: _meetsRequirements,
        documentFile:      _pickedFile,
      );
    }

    if (!mounted) return;
    if (ok) {
      _showSnack(widget.isEditMode
          ? 'Application updated successfully!'
          : 'Application submitted successfully!');
      Navigator.pop(context);
    } else {
      _showSnack(vm.errorMessage ?? 'Something went wrong.', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppTheme.danger : AppTheme.success,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode
            ? 'Edit Application'
            : 'Apply for SA Position'),
      ),
      body: Consumer<ApplicationViewModel>(
        builder: (_, vm, __) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 1. Personal Information ────────────────────────────────
                _sectionTitle('1. Personal Information', Icons.person_outline),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Full name is required';
                    if (v.trim().length < 3)
                      return 'Name must be at least 3 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _numberCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Student Number *',
                    prefixIcon: Icon(Icons.numbers_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Student number is required';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                DropdownButtonFormField<int>(
                  value: _year,
                  decoration: const InputDecoration(
                    labelText: 'Current Year of Study *',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  items: _years.map((y) => DropdownMenuItem(
                      value: y, child: Text('Year $y'))).toList(),
                  onChanged: (v) => setState(() => _year = v),
                  validator: (v) =>
                      v == null ? 'Please select your year of study' : null,
                ),

                const SizedBox(height: 24),
                // ── 2. Module 1 (required) ─────────────────────────────────
                _sectionTitle(
                    '2. Module Application 1 (Required)', Icons.book_outlined),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: _m1Level,
                  decoration: const InputDecoration(
                    labelText: 'Academic Level *',
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                  items: _levels.map((l) => DropdownMenuItem(
                      value: l, child: Text(l))).toList(),
                  onChanged: (v) => setState(() {
                    _m1Level = v;
                    _m1Name  = null;
                  }),
                  validator: (v) =>
                      v == null ? 'Please select an academic level' : null,
                ),
                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  value: _m1Name,
                  decoration: const InputDecoration(
                    labelText: 'Module *',
                    prefixIcon: Icon(Icons.subject_outlined),
                  ),
                  items: (_m1Level != null
                          ? _modules[_m1Level]!
                          : <String>[])
                      .map((m) =>
                          DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) => setState(() => _m1Name = v),
                  validator: (v) =>
                      v == null ? 'Please select a module' : null,
                ),

                const SizedBox(height: 24),
                // ── 3. Module 2 (optional) ─────────────────────────────────
                _sectionTitle(
                    '3. Module Application 2 (Optional)',
                    Icons.add_circle_outline),
                Row(children: [
                  Switch(
                    value: _addM2,
                    activeColor: AppTheme.primary,
                    onChanged: (v) => setState(() {
                      _addM2   = v;
                      if (!v) { _m2Level = null; _m2Name = null; }
                    }),
                  ),
                  const Text('Apply for a second module',
                      style: TextStyle(fontSize: 14)),
                ]),

                if (_addM2) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _m2Level,
                    decoration: const InputDecoration(
                      labelText: 'Academic Level (Module 2) *',
                      prefixIcon: Icon(Icons.school_outlined),
                    ),
                    items: _levels.map((l) => DropdownMenuItem(
                        value: l, child: Text(l))).toList(),
                    onChanged: (v) => setState(() {
                      _m2Level = v;
                      _m2Name  = null;
                    }),
                    validator: (v) => _addM2 && v == null
                        ? 'Please select an academic level for Module 2'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _m2Name,
                    decoration: const InputDecoration(
                      labelText: 'Module (Module 2) *',
                      prefixIcon: Icon(Icons.subject_outlined),
                    ),
                    items: (_m2Level != null
                            ? _modules[_m2Level]!
                            : <String>[])
                        .map((m) =>
                            DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) => setState(() => _m2Name = v),
                    validator: (v) => _addM2 && v == null
                        ? 'Please select a module for Module 2'
                        : null,
                  ),
                ],

                const SizedBox(height: 24),
                // ── 4. Supporting Document ─────────────────────────────────
                _sectionTitle('4. Supporting Documentation',
                    Icons.attach_file_outlined),
                const SizedBox(height: 12),

                OutlinedButton.icon(
                  icon: const Icon(Icons.upload_file_outlined),
                  label: Text(
                    _pickedFile != null
                        ? 'Document selected ✓'
                        : _existingDocUrl != null
                            ? 'Replace existing document'
                            : 'Upload Document (PDF / Image)',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _pickFile,
                ),
                if (_pickedFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Text(
                      _pickedFile!.path.split('/').last,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.success),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (_existingDocUrl != null && _pickedFile == null)
                  const Padding(
                    padding: EdgeInsets.only(top: 6, left: 4),
                    child: Text('Existing document on file ✓',
                        style: TextStyle(fontSize: 12, color: AppTheme.success)),
                  ),

                const SizedBox(height: 24),
                // ── 5. Eligibility Confirmation ────────────────────────────
                _sectionTitle(
                    '5. Eligibility Confirmation', Icons.verified_outlined),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: CheckboxListTile(
                    value: _meetsRequirements,
                    activeColor: AppTheme.primary,
                    onChanged: (v) =>
                        setState(() => _meetsRequirements = v ?? false),
                    title: const Text(
                      'I confirm that I meet the minimum requirements '
                      'for the Student Assistant position, and that all '
                      'information I have provided is accurate and truthful.',
                      style: TextStyle(fontSize: 13),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Submit button ──────────────────────────────────────────
                if (vm.isUploading)
                  const Column(children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Uploading document, please wait…',
                        style: TextStyle(color: AppTheme.textMuted,
                            fontSize: 13)),
                  ])
                else
                  ElevatedButton.icon(
                    icon: const Icon(Icons.send_outlined),
                    label: Text(widget.isEditMode
                        ? 'Update Application'
                        : 'Submit Application'),
                    onPressed: vm.isLoading ? null : _submit,
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(children: [
      Icon(icon, color: AppTheme.primary, size: 20),
      const SizedBox(width: 8),
      Expanded(child: Text(title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
              color: AppTheme.primary))),
    ]),
  );
}
