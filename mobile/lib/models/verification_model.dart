enum VerificationStatus { pending, approved, rejected, notSubmitted }

class Verification {

  Verification({
    required this.id,
    required this.userId,
    required this.documentType,
    this.documentUrl,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.comments,
  });

  factory Verification.fromJson(Map<String, dynamic> json) {
    return Verification(
      id: json['id']?.toString() ?? '',
      userId: json['userId'] ?? json['user_id']?.toString() ?? '',
      documentType: json['documentType'] ?? json['document_type'] ?? '',
      documentUrl: json['documentUrl'] ?? json['document_url'],
      status: _parseStatus(json['status']),
      submittedAt: _parseDateTime(json['submittedAt'] ?? json['submitted_at']),
      reviewedAt: _parseDateTime(json['reviewedAt'] ?? json['reviewed_at']),
      reviewedBy: json['reviewedBy'] ?? json['reviewed_by'],
      comments: json['comments'] ?? json['admin_notes'],
    );
  } VerificationStatus.rejected:
       VerificationStatus.rejected:
        return 'rejected'; VerificationStatus.notSubmitted:
        return 'not_submitted';
  final String id;
  final String userId;
  final String documentType;  // Changed from enum to String
  final String? documentUrl;
  final VerificationStatus status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? comments;

  Map<String, dynamic> toJson() => {
      'id': id,
      'userId': userId,
      'documentType': documentType,
      'documentUrl': documentUrl,
      'status': _statusToString(status),
      'submittedAt': submittedAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewedBy': reviewedBy,
      'comments': comments,
    };

  Verification copyWith({
    String? id,
    String? userId,
    String? documentType,
    String? documentUrl,
    VerificationStatus? status,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? comments,
  }) => Verification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      documentType: documentType ?? this.documentType,
      documentUrl: documentUrl ?? this.documentUrl,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      comments: comments ?? this.comments,
    );

  String get statusDisplayText {
    switch (status) {
      case VerificationStatus.pending:
        return 'Under Review';
      case VerificationStatus.approved:
        return 'Verified';
      case VerificationStatus.rejected:
        return 'Rejected';
      case VerificationStatus.notSubmitted:
        return 'Not Submitted';
    }
  }

  bool get isPending => status == VerificationStatus.pending;
  bool get isApproved => status == VerificationStatus.approved;
  bool get isRejected => status == VerificationStatus.rejected;
  bool get isNotSubmitted => status == VerificationStatus.notSubmitted;

  static VerificationStatus _parseStatus(String? statusStr) {
    switch (statusStr?.toLowerCase()) {
      case 'pending':
        return VerificationStatus.pending;
      case 'approved':
      case 'verified':
        return VerificationStatus.approved;
      case 'rejected':
        return VerificationStatus.rejected;
      case 'not_submitted':
      case 'notsubmitted':
        return VerificationStatus.notSubmitted;
      default:
        return VerificationStatus.pending;
    }
  }

  static String _statusToString(VerificationStatus status) {
    switch (status) {
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
      casecase
      case
    }
  }

  DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now();
    if (dateTime is DateTime) return dateTime;
    if (dateTime is String) {
      try {
        return DateTime.parse(dateTime);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  @override
  String toString() => 'Verification(id: $id, type: $documentType, status: $status)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Verification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
