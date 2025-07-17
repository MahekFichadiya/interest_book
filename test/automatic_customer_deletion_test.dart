import 'package:flutter_test/flutter_test.dart';
import 'package:interest_book/Api/remove_loan.dart';

void main() {
  group('Automatic Customer Deletion Tests', () {
    test('LoanDeletionResult should parse JSON correctly', () {
      // Test successful deletion without customer deletion
      final json1 = {
        "status": "success",
        "message": "Loan successfully deleted and moved to history",
        "customer_deleted": false,
        "remaining_loans": 2
      };
      
      final result1 = LoanDeletionResult.fromJson(json1);
      expect(result1.success, true);
      expect(result1.customerDeleted, false);
      expect(result1.remainingLoans, 2);
      expect(result1.message, "Loan successfully deleted and moved to history");
    });

    test('LoanDeletionResult should handle customer deletion', () {
      // Test successful deletion with customer deletion
      final json2 = {
        "status": "success",
        "message": "Loan deleted and customer automatically removed (no remaining loans)",
        "customer_deleted": true,
        "customer_id": "123"
      };
      
      final result2 = LoanDeletionResult.fromJson(json2);
      expect(result2.success, true);
      expect(result2.customerDeleted, true);
      expect(result2.customerId, "123");
      expect(result2.message, contains("customer automatically removed"));
    });

    test('LoanDeletionResult should handle error cases', () {
      // Test error case
      final json3 = {
        "status": "error",
        "message": "Failed to delete loan"
      };
      
      final result3 = LoanDeletionResult.fromJson(json3);
      expect(result3.success, false);
      expect(result3.customerDeleted, false);
      expect(result3.message, "Failed to delete loan");
    });

    test('LoanDeletionResult should handle missing fields', () {
      // Test with minimal JSON
      final json4 = {
        "status": "success"
      };
      
      final result4 = LoanDeletionResult.fromJson(json4);
      expect(result4.success, true);
      expect(result4.customerDeleted, false);
      expect(result4.message, "");
      expect(result4.customerId, null);
      expect(result4.remainingLoans, null);
    });
  });

  group('Automatic Customer Deletion Logic Demonstration', () {
    test('demonstrates the automatic deletion workflow', () {
      print('\n=== Automatic Customer Deletion Workflow ===');
      
      // Scenario 1: Customer has multiple loans
      print('\nScenario 1: Customer has 3 loans, deleting 1 loan');
      print('- Loan deleted: ✓');
      print('- Remaining loans: 2');
      print('- Customer deleted: ✗ (still has loans)');
      print('- Result: "Loan successfully deleted and moved to history"');
      
      // Scenario 2: Customer has only 1 loan
      print('\nScenario 2: Customer has 1 loan, deleting the last loan');
      print('- Loan deleted: ✓');
      print('- Remaining loans: 0');
      print('- Customer deleted: ✓ (no remaining loans)');
      print('- Result: "Loan deleted and customer automatically removed"');
      
      // Scenario 3: Error case
      print('\nScenario 3: Error during deletion');
      print('- Loan deleted: ✗');
      print('- Customer deleted: ✗');
      print('- Result: "Failed to delete loan"');
      
      print('\n=== Database Operations ===');
      print('1. Delete related interest records');
      print('2. Delete related deposit records');
      print('3. Move loan to historyloan table');
      print('4. Delete loan from loan table');
      print('5. Check remaining loans for customer');
      print('6. If no remaining loans → Delete customer');
      print('7. Commit transaction');
      
      print('\n=== Benefits ===');
      print('✓ Maintains data consistency');
      print('✓ Prevents orphaned customers');
      print('✓ Automatic cleanup');
      print('✓ Transactional safety');
      print('✓ Clear user feedback');
    });
  });
}
