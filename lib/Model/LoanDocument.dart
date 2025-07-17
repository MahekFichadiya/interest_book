class LoanDocument {
  final int documentId;
  final int loanId;
  final String documentPath;
  final String fileName;
  final String? archivedDate; // For history documents

  LoanDocument({
    required this.documentId,
    required this.loanId,
    required this.documentPath,
    required this.fileName,
    this.archivedDate,
  });

  factory LoanDocument.fromJson(Map<String, dynamic> json) {
    return LoanDocument(
      documentId: int.parse(json['documentId'].toString()),
      loanId: int.parse(json['loanId'].toString()),
      documentPath: json['documentPath'] ?? '',
      fileName: json['fileName'] ?? '',
      archivedDate: json['archivedDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'loanId': loanId,
      'documentPath': documentPath,
      'fileName': fileName,
      if (archivedDate != null) 'archivedDate': archivedDate,
    };
  }

  // Get full URL for the document
  String getFullUrl(String baseUrl) {
    return '$baseUrl/$documentPath';
  }

  @override
  String toString() {
    return 'LoanDocument{documentId: $documentId, loanId: $loanId, fileName: $fileName}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanDocument &&
          runtimeType == other.runtimeType &&
          documentId == other.documentId;

  @override
  int get hashCode => documentId.hashCode;
}
