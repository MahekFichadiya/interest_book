<?php

include("Connection.php");

// Start transaction for data consistency
mysqli_autocommit($con, FALSE);

try {
    $json = file_get_contents("php://input");
    $data = json_decode($json);

    $loanId = $data->loanId ?? null;
    $userId = $data->userId ?? null;

    if (!$loanId || !$userId) {
        throw new Exception("Loan ID and User ID are required");
    }

    // Get loan details before deletion
    $loanQuery = "SELECT * FROM loan WHERE loanId = ? AND userId = ?";
    $loanStmt = mysqli_prepare($con, $loanQuery);
    mysqli_stmt_bind_param($loanStmt, "ii", $loanId, $userId);
    mysqli_stmt_execute($loanStmt);
    $loanResult = mysqli_stmt_get_result($loanStmt);
    $loan = mysqli_fetch_assoc($loanResult);

    if (!$loan) {
        throw new Exception("Loan not found or access denied");
    }

    // Check if loan is fully paid (remaining balance is 0 or negative)
    if ($loan['updatedAmount'] > 0) {
        throw new Exception("Loan is not fully paid. Remaining balance: ₹" . $loan['updatedAmount']);
    }

    // Move loan to history table (this will be done automatically by the trigger)
    // But we'll also update the endDate to mark it as settled
    $updateQuery = "UPDATE loan SET endDate = NOW() WHERE loanId = ? AND userId = ?";
    $updateStmt = mysqli_prepare($con, $updateQuery);
    mysqli_stmt_bind_param($updateStmt, "ii", $loanId, $userId);
    
    if (!mysqli_stmt_execute($updateStmt)) {
        throw new Exception("Failed to update loan end date: " . mysqli_error($con));
    }

    // Now delete the loan (trigger will move it to historyloan)
    $deleteQuery = "DELETE FROM loan WHERE loanId = ? AND userId = ?";
    $deleteStmt = mysqli_prepare($con, $deleteQuery);
    mysqli_stmt_bind_param($deleteStmt, "ii", $loanId, $userId);
    
    if (!mysqli_stmt_execute($deleteStmt)) {
        throw new Exception("Failed to settle loan: " . mysqli_error($con));
    }

    // Commit transaction
    mysqli_commit($con);
    
    http_response_code(200);
    echo json_encode([
        "status" => "success",
        "message" => "Loan settled successfully",
        "settledAmount" => $loan['amount'],
        "totalDeposits" => $loan['totalDeposite'],
        "settledDate" => date('Y-m-d H:i:s')
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
