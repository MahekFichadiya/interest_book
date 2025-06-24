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

    // Validate input
    if (empty($depositeAmount) || empty($loanId) || $depositeAmount <= 0) {
        throw new Exception("Invalid deposit amount or loan ID");
    }

    // Insert deposit record
    $depositeQuery = "INSERT INTO deposite (depositeAmount, depositeDate, depositeNote, loanId) VALUES (?, ?, ?, ?)";
    $depositeStmt = mysqli_prepare($con, $depositeQuery);
    mysqli_stmt_bind_param($depositeStmt, "dssi", $depositeAmount, $depositeDate, $depositeNote, $loanId);

    if (!mysqli_stmt_execute($depositeStmt)) {
        throw new Exception("Failed to insert deposit: " . mysqli_error($con));
    }

    // Update loan: deduct deposit from updatedAmount and recalculate interest
    $updateLoanQuery = "UPDATE loan SET
                        updatedAmount = GREATEST(0, updatedAmount - ?)
                        WHERE loanId = ?";
    $updateStmt = mysqli_prepare($con, $updateLoanQuery);
    mysqli_stmt_bind_param($updateStmt, "di", $depositeAmount, $loanId);

    if (!mysqli_stmt_execute($updateStmt)) {
        throw new Exception("Failed to update loan amount: " . mysqli_error($con));
    }

    // Recalculate monthly interest based on new updatedAmount
    $recalculateQuery = "UPDATE loan SET
                         interest = ROUND((updatedAmount * rate) / 100, 2)
                         WHERE loanId = ?";
    $recalculateStmt = mysqli_prepare($con, $recalculateQuery);
    mysqli_stmt_bind_param($recalculateStmt, "i", $loanId);

    if (!mysqli_stmt_execute($recalculateStmt)) {
        throw new Exception("Failed to recalculate interest: " . mysqli_error($con));
    }

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
