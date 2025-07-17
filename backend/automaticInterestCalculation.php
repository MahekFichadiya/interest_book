<?php

include("Connection.php");

/**
 * Enhanced Automatic Interest Calculation System
 * This script calculates monthly interest for all active loans
 * and updates both the interest and totalInterest fields in the loan table
 *
 * Logic:
 * - interest field: stores the current monthly interest amount
 * - totalInterest field: accumulates total interest over time
 * - Calculation: monthlyInterest = updatedAmount * (rate/100)
 */

// Start transaction for data consistency
mysqli_autocommit($con, FALSE);

try {
    // Get all active loans (where endDate is NULL or in the future)
    $activeLoansQuery = "SELECT loanId, amount, rate, updatedAmount, totalDeposite, startDate, endDate,
                                interest, totalInterest, lastInterestUpdatedAt
                         FROM loan
                         WHERE (endDate IS NULL OR endDate > CURDATE())
                         AND updatedAmount > 0";

    $activeLoansResult = mysqli_query($con, $activeLoansQuery);

    if (!$activeLoansResult) {
        throw new Exception("Failed to fetch active loans: " . mysqli_error($con));
    }

    $processedLoans = 0;
    $totalInterestAdded = 0;
    $loansUpdated = [];

    while ($loan = mysqli_fetch_assoc($activeLoansResult)) {
        // Calculate remaining balance (after deposits)
        $remainingBalance = max(0, $loan['updatedAmount']);

        if ($remainingBalance <= 0) {
            continue; // Skip loans with no remaining balance
        }

        // Calculate monthly interest amount
        $monthlyInterestRate = $loan['rate'] / 100;
        $monthlyInterest = round($remainingBalance * $monthlyInterestRate, 2);

        // Determine the date to calculate from
        $startDate = new DateTime($loan['startDate']);
        $currentDate = new DateTime();
        $lastUpdateDate = $loan['lastInterestUpdatedAt'] ?
                         new DateTime($loan['lastInterestUpdatedAt']) : $startDate;

        // Calculate months since last update
        $interval = $lastUpdateDate->diff($currentDate);
        $monthsSinceLastUpdate = ($interval->y * 12) + $interval->m;

        // Always update the monthly interest and daily interest amounts (even if no time has passed)
        // This ensures the interest fields reflect the current calculations
        $dailyInterest = round($monthlyInterest / 30, 2);
        $updateInterestQuery = "UPDATE loan SET interest = ?, dailyInterest = ? WHERE loanId = ?";
        $updateInterestStmt = mysqli_prepare($con, $updateInterestQuery);
        mysqli_stmt_bind_param($updateInterestStmt, "ddi", $monthlyInterest, $dailyInterest, $loan['loanId']);

        if (!mysqli_stmt_execute($updateInterestStmt)) {
            throw new Exception("Failed to update monthly interest for loan ID " . $loan['loanId'] . ": " . mysqli_error($con));
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
            mysqli_stmt_bind_param($updateTotalStmt, "di", $newInterestToAdd, $loan['loanId']);

            if (!mysqli_stmt_execute($updateTotalStmt)) {
                throw new Exception("Failed to update total interest for loan ID " . $loan['loanId'] . ": " . mysqli_error($con));
            }

            $processedLoans++;
            $totalInterestAdded += $newInterestToAdd;

            $loansUpdated[] = [
                'loanId' => $loan['loanId'],
                'monthlyInterest' => $monthlyInterest,
                'interestAdded' => $newInterestToAdd,
                'monthsCalculated' => $monthsSinceLastUpdate,
                'remainingBalance' => $remainingBalance
            ];

            // Log the interest calculation
            error_log("Interest calculated for Loan ID {$loan['loanId']}: Monthly={$monthlyInterest}, Added={$newInterestToAdd}, Months={$monthsSinceLastUpdate}");
        } else {
            // Log that monthly interest was updated even if no accumulation occurred
            error_log("Monthly interest updated for Loan ID {$loan['loanId']}: {$monthlyInterest} (no accumulation - less than 1 month)");
        }
    }

    // Commit all changes
    mysqli_commit($con);

    // Return enhanced success response
    http_response_code(200);
    echo json_encode([
        "status" => "success",
        "message" => "Automatic interest calculation completed successfully",
        "processedLoans" => $processedLoans,
        "totalInterestAdded" => round($totalInterestAdded, 2),
        "calculationDate" => date('Y-m-d H:i:s'),
        "loansUpdated" => $loansUpdated,
        "summary" => [
            "totalActiveLoans" => mysqli_num_rows($activeLoansResult),
            "loansWithInterestAdded" => $processedLoans,
            "averageMonthlyInterest" => $processedLoans > 0 ? round($totalInterestAdded / $processedLoans, 2) : 0
        ]
    ]);

} catch (Exception $e) {
    // Rollback transaction on error
    mysqli_rollback($con);
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => $e->getMessage(),
        "calculationDate" => date('Y-m-d H:i:s'),
        "errorDetails" => [
            "file" => __FILE__,
            "line" => __LINE__
        ]
    ]);
} finally {
    // Restore autocommit
    mysqli_autocommit($con, TRUE);
}
