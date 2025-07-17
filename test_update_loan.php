<?php
// Test script to verify UpdateLoan.php functionality
// This script tests the loan update functionality with different scenarios

include("backend/Connection.php");

echo "=== Testing Update Loan Functionality ===\n\n";

// Test data
$testLoanId = 63; // Using existing loan ID from database
$testUserId = 10;
$testCustId = 9;

// Function to get current loan data
function getCurrentLoanData($con, $loanId) {
    $query = "SELECT loanId, amount, rate, startDate, endDate, note, updatedAmount, totalDeposite, interest, totalInterest, lastInterestUpdatedAt FROM loan WHERE loanId = ?";
    $stmt = $con->prepare($query);
    $stmt->bind_param("i", $loanId);
    $stmt->execute();
    $result = $stmt->get_result();
    return $result->fetch_assoc();
}

// Function to simulate POST request to UpdateLoan.php
function testUpdateLoan($loanId, $amount, $rate, $startDate, $endDate, $note, $userId, $custId) {
    // Simulate POST data
    $_POST = [
        'loanId' => $loanId,
        'amount' => $amount,
        'rate' => $rate,
        'startDate' => $startDate,
        'endDate' => $endDate,
        'note' => $note,
        'userId' => $userId,
        'custId' => $custId
    ];
    
    // Capture output
    ob_start();
    include("backend/UpdateLoan.php");
    $output = ob_get_clean();
    
    return json_decode($output, true);
}

// Get initial loan data
echo "1. Getting initial loan data...\n";
$initialData = getCurrentLoanData($con, $testLoanId);
if ($initialData) {
    echo "Initial Loan Data:\n";
    echo "- Amount: " . $initialData['amount'] . "\n";
    echo "- Rate: " . $initialData['rate'] . "%\n";
    echo "- Start Date: " . $initialData['startDate'] . "\n";
    echo "- Updated Amount: " . $initialData['updatedAmount'] . "\n";
    echo "- Monthly Interest: " . $initialData['interest'] . "\n";
    echo "- Total Interest: " . $initialData['totalInterest'] . "\n";
    echo "- Last Updated: " . $initialData['lastInterestUpdatedAt'] . "\n\n";
} else {
    echo "Loan not found!\n";
    exit;
}

// Test 1: Update amount only
echo "2. Testing amount update (80000 -> 90000)...\n";
$result1 = testUpdateLoan(
    $testLoanId,
    90000, // New amount
    $initialData['rate'],
    $initialData['startDate'],
    $initialData['endDate'],
    $initialData['note'],
    $testUserId,
    $testCustId
);

if ($result1 && $result1['status'] == 'true') {
    echo "✓ Amount update successful\n";
    echo "- New Updated Amount: " . $result1['updatedAmount'] . "\n";
    echo "- New Monthly Interest: " . $result1['newMonthlyInterest'] . "\n";
    echo "- New Total Interest: " . $result1['newTotalInterest'] . "\n";
    echo "- Months Elapsed: " . $result1['monthsElapsed'] . "\n\n";
} else {
    echo "✗ Amount update failed: " . ($result1['message'] ?? 'Unknown error') . "\n\n";
}

// Test 2: Update rate only
echo "3. Testing rate update (1.5% -> 2.0%)...\n";
$result2 = testUpdateLoan(
    $testLoanId,
    90000, // Keep updated amount
    2.0, // New rate
    $initialData['startDate'],
    $initialData['endDate'],
    $initialData['note'],
    $testUserId,
    $testCustId
);

if ($result2 && $result2['status'] == 'true') {
    echo "✓ Rate update successful\n";
    echo "- New Monthly Interest: " . $result2['newMonthlyInterest'] . "\n";
    echo "- New Total Interest: " . $result2['newTotalInterest'] . "\n\n";
} else {
    echo "✗ Rate update failed: " . ($result2['message'] ?? 'Unknown error') . "\n\n";
}

// Test 3: Update start date (affects total interest calculation)
echo "4. Testing start date update...\n";
$newStartDate = '2024-01-01 12:00:00'; // Older date = more months elapsed
$result3 = testUpdateLoan(
    $testLoanId,
    90000,
    2.0,
    $newStartDate,
    $initialData['endDate'],
    $initialData['note'],
    $testUserId,
    $testCustId
);

if ($result3 && $result3['status'] == 'true') {
    echo "✓ Start date update successful\n";
    echo "- New Total Interest: " . $result3['newTotalInterest'] . "\n";
    echo "- Months Elapsed: " . $result3['monthsElapsed'] . "\n\n";
} else {
    echo "✗ Start date update failed: " . ($result3['message'] ?? 'Unknown error') . "\n\n";
}

// Test 4: Update note
echo "5. Testing note update...\n";
$result4 = testUpdateLoan(
    $testLoanId,
    90000,
    2.0,
    $newStartDate,
    $initialData['endDate'],
    'Updated test note - ' . date('Y-m-d H:i:s'),
    $testUserId,
    $testCustId
);

if ($result4 && $result4['status'] == 'true') {
    echo "✓ Note update successful\n\n";
} else {
    echo "✗ Note update failed: " . ($result4['message'] ?? 'Unknown error') . "\n\n";
}

// Get final loan data
echo "6. Final loan data after all updates...\n";
$finalData = getCurrentLoanData($con, $testLoanId);
if ($finalData) {
    echo "Final Loan Data:\n";
    echo "- Amount: " . $finalData['amount'] . "\n";
    echo "- Rate: " . $finalData['rate'] . "%\n";
    echo "- Start Date: " . $finalData['startDate'] . "\n";
    echo "- Updated Amount: " . $finalData['updatedAmount'] . "\n";
    echo "- Monthly Interest: " . $finalData['interest'] . "\n";
    echo "- Total Interest: " . $finalData['totalInterest'] . "\n";
    echo "- Last Updated: " . $finalData['lastInterestUpdatedAt'] . "\n\n";
}

// Restore original data
echo "7. Restoring original loan data...\n";
$restoreResult = testUpdateLoan(
    $testLoanId,
    $initialData['amount'],
    $initialData['rate'],
    $initialData['startDate'],
    $initialData['endDate'],
    $initialData['note'],
    $testUserId,
    $testCustId
);

if ($restoreResult && $restoreResult['status'] == 'true') {
    echo "✓ Original data restored successfully\n";
} else {
    echo "✗ Failed to restore original data\n";
}

echo "\n=== Test Complete ===\n";
?>
