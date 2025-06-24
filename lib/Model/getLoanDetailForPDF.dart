class Getloandetailforpdf {
  Getloandetailforpdf({
    required this.loanId,
    required this.startDate,
    this.endDate,
    required this.duration,
    required this.amount,
    this.loanNote,
    this.depositDetails,
    this.interestDetails,
  });

  late final int loanId;
  late final String startDate;
  String? endDate;
  late final int duration;
  late final int amount;
  String? loanNote;
  String? depositDetails;
  String? interestDetails;

  Getloandetailforpdf.fromJson(Map<String, dynamic> json) {
    loanId = int.tryParse(json['loanId']?.toString() ?? '0') ?? 0;
    startDate = json['startDate']?.toString() ?? '';
    endDate = json['endDate']?.toString();
    duration = int.tryParse(json['duration']?.toString() ?? '0') ?? 0;
    amount = int.tryParse(json['amount']?.toString() ?? '0') ?? 0;
    loanNote = json['loanNote']?.toString();
    depositDetails = json['deposit_details']?.toString();
    interestDetails = json['interest_details']?.toString();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['loanId'] = loanId;
    _data['startDate'] = startDate;
    _data['endDate'] = endDate;
    _data['duration'] = duration;
    _data['amount'] = amount;
    _data['loanNote'] = loanNote;
    _data['deposit_details'] = depositDetails;
    _data['interest_details'] = interestDetails;
    return _data;
  }
}
