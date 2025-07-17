<?php

include("Connection.php");

// Start transaction for data consistency
mysqli_autocommit($con, FALSE);

try {
    $json = file_get_contents("php://input");
    $data = json_decode($json);

    $interestAmount = $data->interestAmount;
    $interestDate = $data->interestDate;
    $interestNote = $data->interestNote;
    $loanId = $data->loanId;
    $interestField = $data->interestField ?? 'cash';

    // Validate input
    if (empty($interestAmount) || empty($loanId) || $interestAmount <= 0) {
        throw new Exception("Invalid interest amount or loan ID");
    }

    // Validate interestField
    if (!in_array($interestField, ['cash', 'online'])) {
        $interestField = 'cash'; // Default to cash if invalid value
    }

    // Check if interestField column exists
    $checkColumnQuery = "SHOW COLUMNS FROM interest LIKE 'interestField'";
    $checkResult = mysqli_query($con, $checkColumnQuery);
    $hasInterestField = mysqli_num_rows($checkResult) > 0;

    // Insert interest payment record with appropriate query based on column existence
    // Note: The database trigger 'deduct_interest_payment' will automatically
    // deduct the payment amount from totalInterest field
    if ($hasInterestField) {
        // Use query with interestField column
        $interestQuery = "INSERT INTO interest (interestAmount, interestDate, interestNote, loanId, interestField) VALUES (?, ?, ?, ?, ?)";
        $interestStmt = mysqli_prepare($con, $interestQuery);
        mysqli_stmt_bind_param($interestStmt, "dssis", $interestAmount, $interestDate, $interestNote, $loanId, $interestField);
    } else {
        // Fallback query without interestField column
        $interestQuery = "INSERT INTO interest (interestAmount, interestDate, interestNote, loanId) VALUES (?, ?, ?, ?)";
        $interestStmt = mysqli_prepare($con, $interestQuery);
        mysqli_stmt_bind_param($interestStmt, "dssi", $interestAmount, $interestDate, $interestNote, $loanId);
    }

    if (!mysqli_stmt_execute($interestStmt)) {
        throw new Exception("Failed to insert interest payment: " . mysqli_error($con));
    }

    // The totalInterest deduction is now handled automatically by the database trigger
    // This ensures consistency and prevents double deduction

    // Commit transaction
    mysqli_commit($con);

    // Return success response with updated loan info
    $loanQuery = "SELECT totalInterest, updatedAmount FROM loan WHERE loanId = ?";
    $loanStmt = mysqli_prepare($con, $loanQuery);
    mysqli_stmt_bind_param($loanStmt, "i", $loanId);
    mysqli_stmt_execute($loanStmt);
    $result = mysqli_stmt_get_result($loanStmt);
    $loanData = mysqli_fetch_assoc($result);

    http_response_code(200);
    echo json_encode([
        "status" => "success",
        "message" => "Interest payment added successfully",
        "totalInterest" => round(floatval($loanData['totalInterest']), 2),
        "updatedAmount" => round(floatval($loanData['updatedAmount']), 2)
    ]);

} catch (Exception $e) {
    // Rollback transaction on error
    mysqli_rollback($con);
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => $e->getMessage()
    ]);
} finally {
    // Restore autocommit
    mysqli_autocommit($con, TRUE);
}