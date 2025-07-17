<?php
// Test loan deletion directly
include "Connection.php";

header('Content-Type: text/plain');

try {
    echo "=== Testing Loan Deletion ===\n\n";
    
    // Step 1: Check if we have any loans to test with
    echo "1. Checking available loans...\n";
    $loansResult = mysqli_query($con, "SELECT loanId, amount, custId FROM loan LIMIT 5");
    if (!$loansResult || mysqli_num_rows($loansResult) == 0) {
        echo "   No loans found in database\n";
        exit;
    }
    
    while ($loan = mysqli_fetch_assoc($loansResult)) {
        echo "   Loan ID: {$loan['loanId']}, Amount: {$loan['amount']}, Customer ID: {$loan['custId']}\n";
    }
    
    // Step 2: Check current triggers
    echo "\n2. Checking current triggers...\n";
    $triggersResult = mysqli_query($con, "SHOW TRIGGERS LIKE 'loan'");
    if ($triggersResult && mysqli_num_rows($triggersResult) > 0) {
        while ($trigger = mysqli_fetch_assoc($triggersResult)) {
            echo "   Trigger: {$trigger['Trigger']} - {$trigger['Timing']} {$trigger['Event']}\n";
        }
    } else {
        echo "   No triggers found for loan table\n";
    }
    
    // Step 3: Test a simple loan deletion (simulate what RemoveLoan.php does)
    echo "\n3. Testing loan deletion process...\n";
    
    // Get the first loan for testing
    mysqli_data_seek($loansResult, 0);
    $testLoan = mysqli_fetch_assoc($loansResult);
    $testLoanId = $testLoan['loanId'];
    
    echo "   Testing with Loan ID: $testLoanId\n";
    
    // Start transaction
    mysqli_autocommit($con, FALSE);
    
    try {
        // Get loan data first
        $getLoanQuery = "SELECT l.*, c.custName FROM loan l 
                         LEFT JOIN customer c ON l.custId = c.custId 
                         WHERE l.loanId = ?";
        $getLoanStmt = mysqli_prepare($con, $getLoanQuery);
        mysqli_stmt_bind_param($getLoanStmt, "i", $testLoanId);
        mysqli_stmt_execute($getLoanStmt);
        $loanResult = mysqli_stmt_get_result($getLoanStmt);
        $loanData = mysqli_fetch_assoc($loanResult);
        
        if (!$loanData) {
            throw new Exception("Loan not found");
        }
        
        echo "   ✓ Loan data retrieved successfully\n";
        
        // Try to delete related records first
        echo "   Deleting related records...\n";
        
        // Delete interest records
        $deleteInterestQuery = "DELETE FROM interest WHERE loanId = ?";
        $interestStmt = mysqli_prepare($con, $deleteInterestQuery);
        mysqli_stmt_bind_param($interestStmt, "i", $testLoanId);
        mysqli_stmt_execute($interestStmt);
        echo "   ✓ Interest records deleted\n";
        
        // Delete deposit records
        $deleteDepositQuery = "DELETE FROM deposite WHERE loanid = ?";
        $depositStmt = mysqli_prepare($con, $deleteDepositQuery);
        mysqli_stmt_bind_param($depositStmt, "i", $testLoanId);
        mysqli_stmt_execute($depositStmt);
        echo "   ✓ Deposit records deleted\n";
        
        // Delete loan documents
        $deleteDocsQuery = "DELETE FROM loan_documents WHERE loanId = ?";
        $deleteDocsStmt = mysqli_prepare($con, $deleteDocsQuery);
        mysqli_stmt_bind_param($deleteDocsStmt, "i", $testLoanId);
        mysqli_stmt_execute($deleteDocsStmt);
        echo "   ✓ Loan documents deleted\n";
        
        // Now try to delete the loan (this will trigger the backup)
        echo "   Attempting to delete loan record...\n";
        $deleteLoanQuery = "DELETE FROM loan WHERE loanId = ?";
        $loanStmt = mysqli_prepare($con, $deleteLoanQuery);
        mysqli_stmt_bind_param($loanStmt, "i", $testLoanId);
        
        if (mysqli_stmt_execute($loanStmt)) {
            $affectedRows = mysqli_stmt_affected_rows($loanStmt);
            echo "   ✓ Loan deleted successfully! Affected rows: $affectedRows\n";
            
            // Check if it was backed up to history
            $checkHistoryQuery = "SELECT COUNT(*) as count FROM historyloan WHERE loanId = ?";
            $historyStmt = mysqli_prepare($con, $checkHistoryQuery);
            mysqli_stmt_bind_param($historyStmt, "i", $testLoanId);
            mysqli_stmt_execute($historyStmt);
            $historyResult = mysqli_stmt_get_result($historyStmt);
            $historyCount = mysqli_fetch_assoc($historyResult)['count'];
            
            if ($historyCount > 0) {
                echo "   ✓ Loan backed up to history table successfully\n";
            } else {
                echo "   ⚠ Loan not found in history table\n";
            }
            
        } else {
            throw new Exception("Failed to delete loan: " . mysqli_stmt_error($loanStmt));
        }
        
        // Rollback the transaction (we don't want to actually delete the loan)
        mysqli_rollback($con);
        echo "   ✓ Transaction rolled back (loan not actually deleted)\n";
        
    } catch (Exception $e) {
        mysqli_rollback($con);
        echo "   ❌ Error during deletion: " . $e->getMessage() . "\n";
    }
    
    mysqli_autocommit($con, TRUE);
    
    echo "\n✅ Loan deletion test completed!\n";
    
} catch (Exception $e) {
    echo "\n❌ Test failed: " . $e->getMessage() . "\n";
}

mysqli_close($con);
?>
