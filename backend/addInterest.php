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

    // Validate input
    if (empty($interestAmount) || empty($loanId) || $interestAmount <= 0) {
        throw new Exception("Invalid interest amount or loan ID");
    }

    // Insert interest payment record
    $interestQuery = "INSERT INTO interest (interestAmount, interestDate, interestNote, loanId) VALUES (?, ?, ?, ?)";
    $interestStmt = mysqli_prepare($con, $interestQuery);
    mysqli_stmt_bind_param($interestStmt, "dssi", $interestAmount, $interestDate, $interestNote, $loanId);

    if (!mysqli_stmt_execute($interestStmt)) {
        throw new Exception("Failed to insert interest payment: " . mysqli_error($con));
    }

    // Update loan: deduct interest payment from totalInterest
    $updateLoanQuery = "UPDATE loan SET
                        totalInterest = GREATEST(0, totalInterest - ?)
                        WHERE loanId = ?";
    $updateStmt = mysqli_prepare($con, $updateLoanQuery);
    mysqli_stmt_bind_param($updateStmt, "di", $interestAmount, $loanId);

    if (!mysqli_stmt_execute($updateStmt)) {
        throw new Exception("Failed to update loan interest: " . mysqli_error($con));
    }

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

?>