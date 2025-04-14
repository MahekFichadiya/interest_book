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
    loanId = json['loanId'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    duration = json['duration'];
    amount = json['amount'];
    loanNote = json['loanNote'];
    depositDetails = json['deposit_details'];
    interestDetails = json['interest_details'];
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
