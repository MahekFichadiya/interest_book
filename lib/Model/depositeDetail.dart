class Depositedetail {
  final String depositeId;
  final String depositeAmount; // ← Will map from interestAmount
  final String depositeDate;   // ← Will map from interestDate
  final String depositeNote;   // ← Will map from interestNote
  final String loanId;

  Depositedetail({
    required this.depositeId,
    required this.depositeAmount,
    required this.depositeDate,
    required this.depositeNote,
    required this.loanId,
  });

  factory Depositedetail.fromJson(Map<String, dynamic> json) {
    return Depositedetail(
      depositeId: json['InterestId'] ?? '',
      depositeAmount: json['interestAmount'] ?? '0',
      depositeDate: json['interestDate'] ?? '',
      depositeNote: json['interestNote'] ?? '',
      loanId: json['loanId'] ?? '', // Make sure the case matches
    );
  }
}
