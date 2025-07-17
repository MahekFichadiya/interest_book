<?php
include "Connection.php";

// Start transaction for data consistency
mysqli_autocommit($con, FALSE);

try {
    $json = file_get_contents('php://input');
    $data = json_decode($json);

    if (!isset($data->depositeId) || !is_numeric($data->depositeId)) {
        throw new Exception("Invalid or missing depositeId");
    }

    $depositeId = intval($data->depositeId);

    // First, get the deposit details to update the loan
    $getDepositQuery = "SELECT depositeAmount, loanId FROM deposite WHERE depositeId = ?";
    $getDepositStmt = mysqli_prepare($con, $getDepositQuery);
    if (!$getDepositStmt) {
        throw new Exception("Failed to prepare get deposit query: " . mysqli_error($con));
    }

    mysqli_stmt_bind_param($getDepositStmt, "i", $depositeId);
    mysqli_stmt_execute($getDepositStmt);
    $result = mysqli_stmt_get_result($getDepositStmt);
    $depositData = mysqli_fetch_assoc($result);

    if (!$depositData) {
        throw new Exception("Deposit not found");
    }

    $depositeAmount = floatval($depositData['depositeAmount']);
    $loanId = intval($depositData['loanId']);

    // Delete the deposit
    $deleteQuery = "DELETE FROM deposite WHERE depositeId = ?";
    $deleteStmt = mysqli_prepare($con, $deleteQuery);
    if (!$deleteStmt) {
        throw new Exception("Failed to prepare delete query: " . mysqli_error($con));
    }

    mysqli_stmt_bind_param($deleteStmt, "i", $depositeId);
    if (!mysqli_stmt_execute($deleteStmt)) {
        throw new Exception("Failed to delete deposit: " . mysqli_stmt_error($deleteStmt));
    }

    // Note: The database trigger 'update_loan_after_deposit_delete' will automatically
    // recalculate the loan's updatedAmount, totalDeposite, interest, and dailyInterest fields
    // based on the remaining deposits. No manual update needed here to avoid double addition.

    // Commit transaction
    mysqli_commit($con);

    // Return success response
    http_response_code(200);
    echo json_encode([
        "status" => "success",
        "message" => "Deposit deleted successfully"
    ]);

} catch (Exception $e) {
    // Rollback transaction on error
    mysqli_rollback($con);
    
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => $e->getMessage()
    ]);
} finally {
    // Restore autocommit
    mysqli_autocommit($con, TRUE);
}

mysqli_close($con);
?>
