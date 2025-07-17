class UrlConstant{
  static const String baseUrl = "http://192.168.123.15/OmJavellerssHTML/";

  static const String showImage = 'http://192.168.123.15';
  static const String LoginApi = '${baseUrl}LoginApi.php';
  static const String SignupApi = '${baseUrl}SignupApi.php';
  static const String FatchCustomer = '${baseUrl}FatchCustomer.php';
  static const String AddCustomer = '${baseUrl}AddCustomer.php';
  static const String getLoanDetail = '${baseUrl}getLoanDetail.php';
  static const String AddLoan = '${baseUrl}AddLoan.php';
  static const String updateLoan = '${baseUrl}UpdateLoan.php';
  static const String removeCustomer = '${baseUrl}RemoveCustomer.php';
  static const String removeLoan = '${baseUrl}RemoveLoan.php';
  static const String UpdateProfile = '${baseUrl}UpdateProfile.php';
  static const String fatchBackupedCustomer = '${baseUrl}fatchBackupedCustomer.php';
  static const String getSettledLoanDetail = '${baseUrl}getSettledLoanDetail.php';
  static const String addInterest = '${baseUrl}addinterest.php';
  static const String removeInterest = '${baseUrl}RemoveInterest.php';
  static const String addDeposite = '${baseUrl}adddeposite.php';
  static const String removeDeposite = '${baseUrl}RemoveDeposite.php';
  static const String fetchInterestdetail = '${baseUrl}fetchInterestdetail.php';
  static const String fetchDepositedetail = '${baseUrl}fetchDepositedetail.php';
  static const String calculateMonthlyInterest = '${baseUrl}calculateMonthlyInterest.php';
  static const String updateMonthlyInterest = '${baseUrl}updateMonthlyInterest.php';
  static const String settleLoan = '${baseUrl}settleLoan.php';
  static const String getCustomerLoanData = '${baseUrl}getCustomerLoanData.php';
  static const String getLoanDetailForPDF = '${baseUrl}getLoanDetailForPDF.php';
  static const String updateCustomer = '${baseUrl}updateCustomer.php';
  static const String getProfileMoneyInfo = '${baseUrl}getProfileMoneyInfo.php';
  static const String getBusinessReportData = '${baseUrl}getBusinessReportData.php';

  // Forgot Password APIs
  static const String sendOTP = '${baseUrl}sendOTP.php';
  static const String verifyOTP = '${baseUrl}verifyOTP.php';
  static const String resetPassword = '${baseUrl}resetPassword.php';

  // Loan Document APIs
  static const String getLoanDocuments = '${baseUrl}getLoanDocuments.php';
  static const String addLoanDocument = '${baseUrl}addLoanDocument.php';
  static const String deleteLoanDocument = '${baseUrl}deleteLoanDocument.php';
  static const String getHistoryLoanDocuments = '${baseUrl}getHistoryLoanDocuments.php';

  // Reminder and Notification APIs
  static const String addReminder = '${baseUrl}addReminder.php';
  static const String getReminders = '${baseUrl}getReminders.php';
  static const String updateReminder = '${baseUrl}updateReminder.php';
  static const String deleteReminder = '${baseUrl}deleteReminder.php';
  static const String generateAutomaticReminders = '${baseUrl}generateAutomaticReminders.php';
  static const String getNotifications = '${baseUrl}getNotifications.php';
  static const String updateNotification = '${baseUrl}updateNotification.php';
  static const String addOverdueNotification = '${baseUrl}addOverdueNotification.php';

  // SMS APIs
  static const String sendSms = '${baseUrl}sendSms.php';
}
