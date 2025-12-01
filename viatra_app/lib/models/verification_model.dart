
enum VerificationStatus {
  pending,
  approved,
  rejected,
  notSubmitted;

  String toJson() {
    switch (this) {
      case VerificationStatus.pending:
        return 'pending';
      case VerificationStatus.approved:
        return 'approved';
      case VerificationStatus.rejected:
        return 'rejected';
      case VerificationStatus.notSubmitted:
        return 'not_submitted';
    }
  }

  static VerificationStatus fromJson(String? value) {
    switch (value?.toLowerCase()) {
      case 'pending':
        return VerificationStatus.pending;
      case 'approved':
        return VerificationStatus.approved;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.notSubmitted;
    }
  }
}

enum DocumentType {
  license,
  certificate,
  idCard;

  String toJson() {
    switch (this) {
      case DocumentType.license:
        return 'license';
      case DocumentType.certificate:
        return 'certificate';
      case DocumentType.idCard:
        return 'id_card';
    }
  }

  static DocumentType fromJson(String? value) {
    switch (value?.toLowerCase()) {
      case 'license':
        return DocumentType.license;
      case 'certificate':
        return DocumentType.certificate;
      case 'id_card':
        return DocumentType.idCard;
      default:
        return DocumentType.license;
    }
  }
}

class Verification {
  final String id;
  final String userId;
  final DocumentType documentType;
  final String documentUrl;
  final VerificationStatus status;
  final String? rejectionReason;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? comments;

  Verification({
    required this.id,
    required this.userId,
    required this.documentType,
    required this.documentUrl,
    required this.status,
    this.rejectionReason,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
    required this.updatedAt,
    this.comments,
  });

  factory Verification.fromJson(Map<String, dynamic> json) {
    return Verification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      documentType: DocumentType.fromJson(json['document_type'] as String?),
      documentUrl: json['document_url'] as String,
      status: VerificationStatus.fromJson(json['status'] as String?),
      rejectionReason: json['rejection_reason'] as String?,
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] != null ? DateTime.parse(json['reviewed_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      comments: json['comments'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'document_type': documentType.toJson(),
      'document_url': documentUrl,
      'status': status.toJson(),
      'rejection_reason': rejectionReason,
      'reviewed_by': reviewedBy,
      'reviewed_at': reviewedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'comments': comments,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Verification && other.id == id && other.userId == userId;
  }

  @override
  int get hashCode => Object.hash(id, userId);
}
