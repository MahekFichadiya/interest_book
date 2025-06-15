import '../Utils/amount_formatter.dart';

class MonthlyInterestCalculation {
  final String loanId;
  final double originalAmount;
  final double remainingBalance;
  final double monthlyInterestRate;
  final double monthlyInterest;
  final int totalMonths;
  final double totalAccumulatedInterest;
  final double totalDeposits;
  final double totalInterestPaid;
  final double netAmountDue;

  MonthlyInterestCalculation({
    required this.loanId,
    required this.originalAmount,
    required this.remainingBalance,
    required this.monthlyInterestRate,
    required this.monthlyInterest,
    required this.totalMonths,
    required this.totalAccumulatedInterest,
    required this.totalDeposits,
    required this.totalInterestPaid,
    required this.netAmountDue,
  });

  factory MonthlyInterestCalculation.fromJson(Map<String, dynamic> json) {
    return MonthlyInterestCalculation(
      loanId: json['loanId']?.toString() ?? '',
      originalAmount: double.tryParse(json['originalAmount']?.toString() ?? '0') ?? 0.0,
      remainingBalance: double.tryParse(json['remainingBalance']?.toString() ?? '0') ?? 0.0,
      monthlyInterestRate: double.tryParse(json['monthlyInterestRate']?.toString() ?? '0') ?? 0.0,
      monthlyInterest: double.tryParse(json['monthlyInterest']?.toString() ?? '0') ?? 0.0,
      totalMonths: int.tryParse(json['totalMonths']?.toString() ?? '0') ?? 0,
      totalAccumulatedInterest: double.tryParse(json['totalAccumulatedInterest']?.toString() ?? '0') ?? 0.0,
      totalDeposits: double.tryParse(json['totalDeposits']?.toString() ?? '0') ?? 0.0,
      totalInterestPaid: double.tryParse(json['totalInterestPaid']?.toString() ?? '0') ?? 0.0,
      netAmountDue: double.tryParse(json['netAmountDue']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'loanId': loanId,
      'originalAmount': originalAmount,
      'remainingBalance': remainingBalance,
      'monthlyInterestRate': monthlyInterestRate,
      'monthlyInterest': monthlyInterest,
      'totalMonths': totalMonths,
      'totalAccumulatedInterest': totalAccumulatedInterest,
      'totalDeposits': totalDeposits,
      'totalInterestPaid': totalInterestPaid,
      'netAmountDue': netAmountDue,
    };
  }

  // Helper methods for formatting using the centralized formatter
  String get formattedOriginalAmount => AmountFormatter.formatCurrency(originalAmount);
  String get formattedRemainingBalance => AmountFormatter.formatCurrency(remainingBalance);
  String get formattedMonthlyInterest => AmountFormatter.formatCurrencyWithDecimals(monthlyInterest);
  String get formattedTotalAccumulatedInterest => AmountFormatter.formatCurrencyWithDecimals(totalAccumulatedInterest);
  String get formattedTotalDeposits => AmountFormatter.formatCurrency(totalDeposits);
  String get formattedTotalInterestPaid => AmountFormatter.formatCurrencyWithDecimals(totalInterestPaid);
  String get formattedNetAmountDue => AmountFormatter.formatCurrencyWithDecimals(netAmountDue);
  String get formattedMonthlyInterestRate => AmountFormatter.formatPercentage(monthlyInterestRate);

  // Additional formatting methods
  String get formattedDailyInterest => AmountFormatter.formatDailyInterest(monthlyInterest);
  String get formattedCompactOriginalAmount => AmountFormatter.formatCompactCurrency(originalAmount);
  String get formattedCompactNetAmountDue => AmountFormatter.formatCompactCurrency(netAmountDue);
}
