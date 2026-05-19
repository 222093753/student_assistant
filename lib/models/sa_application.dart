/**
 * Student Numbers: 222093753, 223005951, 221045356, 221032445, 223082890,
 * Student Names  : DM Skitla, KL Boisa, TD Mokoena, KD Hlokoane, SD Tshabalala,
 * Question: sa_application.dart - Data Model for Student Assistant Applications
 */

class SAApplication {
  final String id;
  final String userId;
  final String studentName;
  final String studentNumber;
  final int yearOfStudy;

  // Module 1 (required)
  final String module1Level;
  final String module1Name;

  // Module 2 (optional – max 2 modules per application)
  final String? module2Level;
  final String? module2Name;

  final bool meetsRequirements;
  final String? documentUrl;
  final String status; // 'pending' | 'approved' | 'rejected'
  final String? adminComment;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SAApplication({
    required this.id,
    required this.userId,
    required this.studentName,
    required this.studentNumber,
    required this.yearOfStudy,
    required this.module1Level,
    required this.module1Name,
    this.module2Level,
    this.module2Name,
    required this.meetsRequirements,
    this.documentUrl,
    required this.status,
    this.adminComment,
    required this.createdAt,
    required this.updatedAt,
  });

  // ── JSON → Model (Supabase response) ────────────────────────────────────
  factory SAApplication.fromJson(Map<String, dynamic> json) {
    return SAApplication(
      id:                 json['id'].toString(),
      userId:             json['user_id'].toString(),
      studentName:        json['student_name'] ?? '',
      studentNumber:      json['student_number'] ?? '',
      yearOfStudy: int.tryParse(json['year_of_study'].toString()) ?? 1,
      module1Level:       json['module1_level'] ?? '',
      module1Name:        json['module1_name'] ?? '',
      module2Level:       json['module2_level'],
      module2Name:        json['module2_name'],
      meetsRequirements:  json['meets_requirements'] ?? false,
      documentUrl:        json['document_url'],
      status:             json['status'] ?? 'pending',
      adminComment:       json['admin_comment'],
      createdAt:          DateTime.parse(json['created_at']),
      updatedAt:          DateTime.parse(json['updated_at']),
    );
  }

  // ── Model → JSON (Supabase insert/update) ───────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'student_name':      studentName,
      'student_number':    studentNumber,
      'year_of_study':     yearOfStudy,
      'module1_level':     module1Level,
      'module1_name':      module1Name,
      if (module2Level != null && module2Level!.isNotEmpty)
        'module2_level':   module2Level,
      if (module2Name != null && module2Name!.isNotEmpty)
        'module2_name':    module2Name,
      'meets_requirements': meetsRequirements,
      if (documentUrl != null) 'document_url': documentUrl,
      'status':            status,
    };
  }

  // ── copyWith ─────────────────────────────────────────────────────────────
  SAApplication copyWith({
    String? status,
    String? adminComment,
    String? documentUrl,
    String? studentName,
    String? studentNumber,
    int? yearOfStudy,
    String? module1Level,
    String? module1Name,
    String? module2Level,
    String? module2Name,
    bool? meetsRequirements,
    DateTime? updatedAt,
  }) {
    return SAApplication(
      id:                 id,
      userId:             userId,
      studentName:        studentName        ?? this.studentName,
      studentNumber:      studentNumber      ?? this.studentNumber,
      yearOfStudy:        yearOfStudy        ?? this.yearOfStudy,
      module1Level:       module1Level       ?? this.module1Level,
      module1Name:        module1Name        ?? this.module1Name,
      module2Level:       module2Level       ?? this.module2Level,
      module2Name:        module2Name        ?? this.module2Name,
      meetsRequirements:  meetsRequirements  ?? this.meetsRequirements,
      documentUrl:        documentUrl        ?? this.documentUrl,
      status:             status             ?? this.status,
      adminComment:       adminComment       ?? this.adminComment,
      createdAt:          createdAt,
      updatedAt:          updatedAt          ?? this.updatedAt,
    );
  }

  // ── Computed helpers ─────────────────────────────────────────────────────
  bool get isPending      => status == 'pending';
  bool get isApproved     => status == 'approved';
  bool get isRejected     => status == 'rejected';
  bool get hasSecondModule =>
      module2Name != null && module2Name!.isNotEmpty;
}
