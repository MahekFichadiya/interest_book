<?php
// Test script to verify loan update functionality
include("Connection.php");

header('Content-Type: application/json');

// Test data
$testLoanId = 63; // Using the loan ID from your database

try {
    // Get current loan data before update
    $beforeQuery = "SELECT loanId, amount, rate, updatedAmount, totalDeposite, interest FROM loan WHERE loanId = ?";
    $beforeStmt = $con->prepare($beforeQuery);
    $beforeStmt->bind_param("i", $testLoanId);
    $beforeStmt->execute();
    $beforeResult = $beforeStmt->get_result();
    $beforeData = $beforeResult->fetch_assoc();
    
    // Get deposits for this loan
    $depositQuery = "SELECT depositeId, depositeAmount, depositeDate FROM deposite WHERE loanid = ?";
    $depositStmt = $con->prepare($depositQuery);
    $depositStmt->bind_param("i", $testLoanId);
    $depositStmt->execute();
    $depositResult = $depositStmt->get_result();
    $deposits = [];
    while ($row = $depositResult->fetch_assoc()) {
        $deposits[] = $row;
    }
    
    // Calculate expected values
    $totalDeposits = 0;
    foreach ($deposits as $deposit) {
        $totalDeposits += $deposit['depositeAmount'];
    }
    
    $expectedUpdatedAmount = max(0, $beforeData['amount'] - $totalDeposits);
    $expectedMonthlyInterest = round(($expectedUpdatedAmount * $beforeData['rate']) / 100, 2);
    
    echo json_encode([
        "status" => "success",
        "testLoanId" => $testLoanId,
        "currentLoanData" => $beforeData,
        "deposits" => $deposits,
        "calculations" => [
            "totalDeposits" => $totalDeposits,
            "expectedUpdatedAmount" => $expectedUpdatedAmount,
            "expectedMonthlyInterest" => $expectedMonthlyInterest,
            "isCorrect" => [
                "totalDeposite" => ($beforeData['totalDeposite'] == $totalDeposits),
                "updatedAmount" => ($beforeData['updatedAmount'] == $expectedUpdatedAmount),
                "interest" => (abs($beforeData['interest'] - $expectedMonthlyInterest) < 0.01)
            ]
        ],
        "message" => "Test completed. Check 'isCorrect' values to verify calculations."
    ], JSON_PRETTY_PRINT);
    
} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => $e->getMessage()
    ]);
}

$con->close();
?>
