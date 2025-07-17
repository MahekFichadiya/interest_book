<?php

include("Connection.php");

// Start transaction for data consistency
mysqli_autocommit($con, FALSE);

try {
    $json = file_get_contents("php://input");
    $data = json_decode($json);

    $depositeAmount = $data->depositeAmount;
    $depositeDate = $data->depositeDate;
    $depositeNote = $data->depositeNote;
    $loanId = $data->loanId;
    $depositeField = $data->depositeField ?? 'cash';

    // Validate input
    if (empty($depositeAmount) || empty($loanId) || $depositeAmount <= 0) {
        throw new Exception("Invalid deposit amount or loan ID");
    }

    // Validate depositeField
    if (!in_array($depositeField, ['cash', 'online'])) {
        $depositeField = 'cash'; // Default to cash if invalid value
    }

    // Check if depositeField column exists
    $checkColumnQuery = "SHOW COLUMNS FROM deposite LIKE 'depositeField'";
    $checkResult = mysqli_query($con, $checkColumnQuery);
    $hasDepositeField = mysqli_num_rows($checkResult) > 0;

    // Insert deposit record with appropriate query based on column existence
    if ($hasDepositeField) {
        // Use query with depositeField column (using correct column name: loanid instead of loanId)
        $depositeQuery = "INSERT INTO deposite (depositeAmount, depositeDate, depositeNote, loanid, depositeField) VALUES (?, ?, ?, ?, ?)";
        $depositeStmt = mysqli_prepare($con, $depositeQuery);
        mysqli_stmt_bind_param($depositeStmt, "dssis", $depositeAmount, $depositeDate, $depositeNote, $loanId, $depositeField);
    } else {
        // Fallback query without depositeField column
        $depositeQuery = "INSERT INTO deposite (depositeAmount, depositeDate, depositeNote, loanid) VALUES (?, ?, ?, ?)";
        $depositeStmt = mysqli_prepare($con, $depositeQuery);
        mysqli_stmt_bind_param($depositeStmt, "dssi", $depositeAmount, $depositeDate, $depositeNote, $loanId);
    }

    if (!mysqli_stmt_execute($depositeStmt)) {
        throw new Exception("Failed to insert deposit: " . mysqli_error($con));
    }

    // Note: The database trigger 'update_loan_after_deposit_insert' will automatically
    // update the loan's updatedAmount, totalDeposite, interest, and dailyInterest fields
    // based on the total deposits. No manual update needed here to avoid double deduction.

    // Commit transaction
    mysqli_commit($con);

    // Return success response with updated loan info
    $loanQuery = "SELECT updatedAmount, interest, totalInterest FROM loan WHERE loanId = ?";
    $loanStmt = mysqli_prepare($con, $loanQuery);
    mysqli_stmt_bind_param($loanStmt, "i", $loanId);
    mysqli_stmt_execute($loanStmt);
    $result = mysqli_stmt_get_result($loanStmt);
    $loanData = mysqli_fetch_assoc($result);

    http_response_code(200);
    echo json_encode([
        "status" => "success",
        "message" => "Deposit added successfully",
        "updatedAmount" => round(floatval($loanData['updatedAmount']), 2),
        "monthlyInterest" => round(floatval($loanData['interest']), 2),
        "totalInterest" => round(floatval($loanData['totalInterest']), 2)
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

?>
