<?php

include("Connection.php");

/**
 * Calculate Monthly Interest for Specific Loan
 * This script calculates and stores monthly interest for a specific loan
 *
 * Logic:
 * - interest field: stores the current monthly interest amount
 * - totalInterest field: accumulates total interest over time
 * - Calculation: monthlyInterest = updatedAmount * (rate/100)
 */

// Start transaction for data consistency
mysqli_autocommit($con, FALSE);

try {
    $json = file_get_contents("php://input");
    $data = json_decode($json);

    $loanId = $data->loanId ?? null;

    if (!$loanId) {
        http_response_code(400);
        echo json_encode([
            "status" => "error",
            "message" => "loanId is required"
        ]);
        exit;
    }

    // Get loan details
    $loanQuery = "SELECT loanId, amount, rate, updatedAmount, totalDeposite, startDate, endDate,
                         interest, totalInterest, lastInterestUpdatedAt
                  FROM loan WHERE loanId = ?";
    $loanStmt = mysqli_prepare($con, $loanQuery);
    mysqli_stmt_bind_param($loanStmt, "i", $loanId);
    mysqli_stmt_execute($loanStmt);
    $loanResult = mysqli_stmt_get_result($loanStmt);
    $loan = mysqli_fetch_assoc($loanResult);

    if (!$loan) {
        throw new Exception("Loan not found with ID: " . $loanId);
    }

    // Calculate remaining balance (updated amount after deposits)
    $remainingBalance = max(0, $loan['updatedAmount']);

    // Calculate monthly interest on remaining balance
    $monthlyInterestRate = $loan['rate'] / 100; // Convert percentage to decimal
    $monthlyInterest = round($remainingBalance * $monthlyInterestRate, 2);

    // Calculate months since loan start or last interest update
    $startDate = new DateTime($loan['startDate']);
    $currentDate = new DateTime();
    $lastUpdateDate = $loan['lastInterestUpdatedAt'] ? new DateTime($loan['lastInterestUpdatedAt']) : $startDate;

    // Calculate months since last update
    $interval = $lastUpdateDate->diff($currentDate);
    $monthsSinceLastUpdate = $interval->y * 12 + $interval->m;

    // Always update the monthly interest amount (ensures current calculation)
    $updateInterestQuery = "UPDATE loan SET interest = ? WHERE loanId = ?";
    $updateInterestStmt = mysqli_prepare($con, $updateInterestQuery);
    mysqli_stmt_bind_param($updateInterestStmt, "di", $monthlyInterest, $loanId);

    if (!mysqli_stmt_execute($updateInterestStmt)) {
        throw new Exception("Failed to update monthly interest: " . mysqli_error($con));
    }

    // Only add to totalInterest if at least one month has passed
    if ($monthsSinceLastUpdate > 0) {
        $newInterestToAdd = $monthlyInterest * $monthsSinceLastUpdate;

        // Update loan with accumulated interest
        $updateTotalQuery = "UPDATE loan SET
                            totalInterest = totalInterest + ?,
                            lastInterestUpdatedAt = CURDATE()
                            WHERE loanId = ?";
        $updateTotalStmt = mysqli_prepare($con, $updateTotalQuery);
        mysqli_stmt_bind_param($updateTotalStmt, "di", $newInterestToAdd, $loanId);

        if (!mysqli_stmt_execute($updateTotalStmt)) {
            throw new Exception("Failed to update total interest: " . mysqli_error($con));
        }

        // Commit transaction
        mysqli_commit($con);

        // Get updated loan data
        mysqli_stmt_execute($loanStmt);
        $updatedResult = mysqli_stmt_get_result($loanStmt);
        $updatedLoan = mysqli_fetch_assoc($updatedResult);

        http_response_code(200);
        echo json_encode([
            "status" => "success",
            "message" => "Interest calculated and updated successfully",
            "data" => [
                "loanId" => $loanId,
                "monthlyInterest" => $monthlyInterest,
                "interestAdded" => round($newInterestToAdd, 2),
                "totalInterest" => round(floatval($updatedLoan['totalInterest']), 2),
                "remainingBalance" => $remainingBalance,
                "monthsCalculated" => $monthsSinceLastUpdate,
                "lastUpdated" => $updatedLoan['lastInterestUpdatedAt'],
                "calculationDate" => date('Y-m-d H:i:s')
            ]
        ]);
    } else {
        // Commit the monthly interest update
        mysqli_commit($con);

        // No accumulated interest to add yet, but monthly interest is updated
        http_response_code(200);
        echo json_encode([
            "status" => "success",
            "message" => "Monthly interest updated, no accumulation needed yet",
            "data" => [
                "loanId" => $loanId,
                "monthlyInterest" => $monthlyInterest,
                "totalInterest" => round(floatval($loan['totalInterest']), 2),
                "remainingBalance" => $remainingBalance,
                "lastUpdated" => $loan['lastInterestUpdatedAt'],
                "calculationDate" => date('Y-m-d H:i:s'),
                "note" => "Less than 1 month since last update"
            ]
        ]);
    }

} catch (Exception $e) {
    // Rollback transaction on error
    mysqli_rollback($con);
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => $e->getMessage(),
        "errorDetails" => [
            "loanId" => $loanId ?? null,
            "file" => __FILE__,
            "line" => __LINE__,
            "timestamp" => date('Y-m-d H:i:s')
        ]
    ]);
} finally {
    // Restore autocommit
    mysqli_autocommit($con, TRUE);
}