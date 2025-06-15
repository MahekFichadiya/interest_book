class Depositedetail {
  final String depositeId;
  final String depositeAmount;
  final String depositeDate;
  final String depositeNote;
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
      depositeId: json['depositeId']?.toString() ?? '',
      depositeAmount: json['depositeAmount']?.toString() ?? '0',
      depositeDate: json['depositeDate']?.toString() ?? '',
      depositeNote: json['depositeNote']?.toString() ?? '',
      loanId: json['loanId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'depositeId': depositeId,
      'depositeAmount': depositeAmount,
      'depositeDate': depositeDate,
      'depositeNote': depositeNote,
      'loanId': loanId,
    };
  }
}
