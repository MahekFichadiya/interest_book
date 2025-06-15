<?php

include("Connection.php");

/**
 * Update Monthly Interest for All Active Loans
 * This script specifically updates the 'interest' field in the loan table
 * to store the current monthly interest amount for each loan
 * 
 * Purpose:
 * - Ensures the 'interest' field always contains the current monthly interest
 * - Calculation: interest = updatedAmount * (rate/100)
 * - Does NOT accumulate to totalInterest (that's handled separately)
 */

// Set response headers
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Start transaction for data consistency
mysqli_autocommit($con, FALSE);

try {
    // Get all active loans
    $activeLoansQuery = "SELECT loanId, amount, rate, updatedAmount, totalDeposite, startDate, endDate, 
                                interest, totalInterest, lastInterestUpdatedAt
                         FROM loan 
                         WHERE (endDate IS NULL OR endDate > CURDATE()) 
                         AND updatedAmount > 0";
    
    $activeLoansResult = mysqli_query($con, $activeLoansQuery);
    
    if (!$activeLoansResult) {
        throw new Exception("Failed to fetch active loans: " . mysqli_error($con));
    }
    
    $updatedLoans = 0;
    $loansProcessed = [];
    
    while ($loan = mysqli_fetch_assoc($activeLoansResult)) {
        // Calculate remaining balance (after deposits)
        $remainingBalance = max(0, $loan['updatedAmount']);
        
        if ($remainingBalance <= 0) {
            continue; // Skip loans with no remaining balance
        }
        
        // Calculate monthly interest amount
        $monthlyInterestRate = $loan['rate'] / 100;
        $monthlyInterest = round($remainingBalance * $monthlyInterestRate, 2);
        
        // Update the monthly interest field
        $updateQuery = "UPDATE loan SET interest = ? WHERE loanId = ?";
        $updateStmt = mysqli_prepare($con, $updateQuery);
        mysqli_stmt_bind_param($updateStmt, "di", $monthlyInterest, $loan['loanId']);
        
        if (!mysqli_stmt_execute($updateStmt)) {
            throw new Exception("Failed to update monthly interest for loan ID " . $loan['loanId'] . ": " . mysqli_error($con));
        }
        
        $updatedLoans++;
        $loansProcessed[] = [
            'loanId' => $loan['loanId'],
            'remainingBalance' => $remainingBalance,
            'interestRate' => $loan['rate'],
            'monthlyInterest' => $monthlyInterest,
            'previousInterest' => $loan['interest']
        ];
        
        // Log the update
        error_log("Monthly interest updated for Loan ID {$loan['loanId']}: {$monthlyInterest} (Balance: {$remainingBalance}, Rate: {$loan['rate']}%)");
    }
    
    // Commit all changes
    mysqli_commit($con);
    
    // Return success response
    http_response_code(200);
    echo json_encode([
        "status" => "success",
        "message" => "Monthly interest updated for all active loans",
        "data" => [
            "totalActiveLoans" => mysqli_num_rows($activeLoansResult),
            "loansUpdated" => $updatedLoans,
            "updateDate" => date('Y-m-d H:i:s'),
            "loansProcessed" => $loansProcessed
        ]
    ]);
    
} catch (Exception $e) {
    // Rollback transaction on error
    mysqli_rollback($con);
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => $e->getMessage(),
        "errorDetails" => [
            "file" => __FILE__,
            "line" => __LINE__,
            "timestamp" => date('Y-m-d H:i:s')
        ]
    ]);
} finally {
    // Restore autocommit
    mysqli_autocommit($con, TRUE);
}
