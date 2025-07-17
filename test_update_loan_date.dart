import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 Starting Update Loan Date Test...\n');

  // Test data - using the loan we just created
  final String baseUrl = 'http://192.168.20.15/OmJavellerssHTML';
  final String loanId = '74'; // The loan we just created
  final String userId = '11';
  final String custId = '39';

  try {
    // Test 1: Get current loan data
    print('1. Getting current loan data...');
    final currentData = await getLoanData(baseUrl, userId, custId);
    if (currentData != null && currentData.isNotEmpty) {
      final loan = currentData.firstWhere((l) => l['loanId'] == loanId, orElse: () => {});
      if (loan.isNotEmpty) {
        print('✓ Current loan found:');
        print('  - Amount: ${loan['amount']}');
        print('  - Rate: ${loan['rate']}%');
        print('  - Start Date: ${loan['startDate']}');
        print('  - Total Interest: ${loan['totalInterest']}');
        print('  - Monthly Interest: ${loan['interest']}');
        print('');

        // Test 2: Update start date to 1 month ago
        print('2. Testing start date update (1 month ago)...');
        final oneMonthAgo = DateTime.now().subtract(Duration(days: 30));
        final newStartDate = '${oneMonthAgo.day.toString().padLeft(2, '0')}/${oneMonthAgo.month.toString().padLeft(2, '0')}/${oneMonthAgo.year} ${oneMonthAgo.hour.toString().padLeft(2, '0')}:${oneMonthAgo.minute.toString().padLeft(2, '0')} ${oneMonthAgo.hour >= 12 ? 'PM' : 'AM'}';
        
        print('  - New start date: $newStartDate');
        
        final updateResult = await updateLoan(
          baseUrl,
          loanId,
          loan['amount'],
          loan['rate'],
          newStartDate,
          loan['endDate'] == '0000-00-00' ? '' : loan['endDate'],
          loan['note'],
          userId,
          custId,
        );

        if (updateResult != null && updateResult['status'] == 'true') {
          print('✓ Update successful!');
          print('  - New Updated Amount: ${updateResult['updatedAmount']}');
          print('  - New Monthly Interest: ${updateResult['newMonthlyInterest']}');
          print('  - New Total Interest: ${updateResult['newTotalInterest']}');
          print('  - Months Elapsed: ${updateResult['monthsElapsed']}');
          print('  - Total Interest Paid: ${updateResult['totalInterestPaid']}');
          print('');

          // Test 3: Verify the update in database
          print('3. Verifying update in database...');
          final updatedData = await getLoanData(baseUrl, userId, custId);
          if (updatedData != null && updatedData.isNotEmpty) {
            final updatedLoan = updatedData.firstWhere((l) => l['loanId'] == loanId, orElse: () => {});
            if (updatedLoan.isNotEmpty) {
              print('✓ Database verification:');
              print('  - Start Date: ${updatedLoan['startDate']}');
              print('  - Total Interest: ${updatedLoan['totalInterest']}');
              print('  - Monthly Interest: ${updatedLoan['interest']}');
              print('  - Last Updated: ${updatedLoan['lastInterestUpdatedAt']}');
              
              // Check if total interest was calculated correctly
              final expectedTotalInterest = double.parse(updatedLoan['interest']) * int.parse(updateResult['monthsElapsed'].toString());
              final actualTotalInterest = double.parse(updatedLoan['totalInterest']);
              
              print('');
              print('📊 Calculation Verification:');
              print('  - Expected Total Interest: ${expectedTotalInterest.toStringAsFixed(2)}');
              print('  - Actual Total Interest: ${actualTotalInterest.toStringAsFixed(2)}');
              
              if ((expectedTotalInterest - actualTotalInterest).abs() < 0.01) {
                print('✅ CALCULATION CORRECT!');
              } else {
                print('❌ CALCULATION INCORRECT!');
              }
            }
          }

          // Test 4: Restore original date
          print('\n4. Restoring original start date...');
          final restoreResult = await updateLoan(
            baseUrl,
            loanId,
            loan['amount'],
            loan['rate'],
            formatDateForDisplay(loan['startDate']),
            loan['endDate'] == '0000-00-00' ? '' : loan['endDate'],
            loan['note'],
            userId,
            custId,
          );

          if (restoreResult != null && restoreResult['status'] == 'true') {
            print('✓ Original date restored successfully');
          } else {
            print('❌ Failed to restore original date');
          }

        } else {
          print('❌ Update failed: ${updateResult?['message'] ?? 'Unknown error'}');
        }
      } else {
        print('❌ Loan with ID $loanId not found');
      }
    } else {
      print('❌ No loan data found');
    }

  } catch (e) {
    print('❌ Error: $e');
  }

  print('\n🏁 Test Complete!');
}

Future<List<dynamic>?> getLoanData(String baseUrl, String userId, String custId) async {
  try {
    final url = Uri.parse('$baseUrl/getLoanDetail.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userId': userId, 'custId': custId}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
  } catch (e) {
    print('Error getting loan data: $e');
  }
  return null;
}

Future<Map<String, dynamic>?> updateLoan(
  String baseUrl,
  String loanId,
  String amount,
  String rate,
  String startDate,
  String endDate,
  String note,
  String userId,
  String custId,
) async {
  try {
    final url = Uri.parse('$baseUrl/UpdateLoan.php');
    final request = http.MultipartRequest('POST', url);
    
    request.fields['loanId'] = loanId;
    request.fields['amount'] = amount;
    request.fields['rate'] = rate;
    request.fields['startDate'] = convertDateToMySQLFormat(startDate);
    request.fields['endDate'] = endDate.isNotEmpty ? convertDateToMySQLFormat(endDate) : '';
    request.fields['note'] = note;
    request.fields['userId'] = userId;
    request.fields['custId'] = custId;

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    
    return json.decode(responseData) as Map<String, dynamic>;
  } catch (e) {
    print('Error updating loan: $e');
    return null;
  }
}

String convertDateToMySQLFormat(String dateStr) {
  try {
    // Parse from "dd/MM/yyyy HH:mm a" format
    final parts = dateStr.split(' ');
    final datePart = parts[0]; // dd/MM/yyyy
    final timePart = parts.length > 1 ? parts[1] : '00:00'; // HH:mm
    final amPm = parts.length > 2 ? parts[2] : 'AM'; // a
    
    final dateParts = datePart.split('/');
    final day = dateParts[0];
    final month = dateParts[1];
    final year = dateParts[2];
    
    final timeParts = timePart.split(':');
    var hour = int.parse(timeParts[0]);
    final minute = timeParts[1];
    
    // Convert to 24-hour format
    if (amPm.toUpperCase() == 'PM' && hour != 12) {
      hour += 12;
    } else if (amPm.toUpperCase() == 'AM' && hour == 12) {
      hour = 0;
    }
    
    return '$year-$month-$day ${hour.toString().padLeft(2, '0')}:$minute:00';
  } catch (e) {
    print('Error converting date: $e');
    return dateStr;
  }
}

String formatDateForDisplay(String mysqlDate) {
  try {
    final dateTime = DateTime.parse(mysqlDate);
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
    
    return '$day/$month/$year ${hour.toString().padLeft(2, '0')}:$minute $amPm';
  } catch (e) {
    return mysqlDate;
  }
}
