<?php
include "Connection.php";

// Start transaction for data consistency
mysqli_autocommit($con, FALSE);

try {
    $json = file_get_contents('php://input');
    $data = json_decode($json);

    if (!isset($data->interestId) || !is_numeric($data->interestId)) {
        throw new Exception("Invalid or missing interestId");
    }

    $interestId = intval($data->interestId);

    // First, get the interest details to update the loan
    $getInterestQuery = "SELECT interestAmount, loanId FROM interest WHERE InterestId = ?";
    $getInterestStmt = mysqli_prepare($con, $getInterestQuery);
    if (!$getInterestStmt) {
        throw new Exception("Failed to prepare get interest query: " . mysqli_error($con));
    }

    mysqli_stmt_bind_param($getInterestStmt, "i", $interestId);
    mysqli_stmt_execute($getInterestStmt);
    $result = mysqli_stmt_get_result($getInterestStmt);
    $interestData = mysqli_fetch_assoc($result);

    if (!$interestData) {
        throw new Exception("Interest record not found");
    }

    $interestAmount = floatval($interestData['interestAmount']);
    $loanId = intval($interestData['loanId']);

    // Delete the interest record
    $deleteQuery = "DELETE FROM interest WHERE InterestId = ?";
    $deleteStmt = mysqli_prepare($con, $deleteQuery);
    if (!$deleteStmt) {
        throw new Exception("Failed to prepare delete query: " . mysqli_error($con));
    }

    mysqli_stmt_bind_param($deleteStmt, "i", $interestId);
    if (!mysqli_stmt_execute($deleteStmt)) {
        throw new Exception("Failed to delete interest: " . mysqli_stmt_error($deleteStmt));
    }

    // Update the loan's totalInterest by adding back the deleted interest payment
    // Since interest payments reduce totalInterest, we need to add it back when deleting
    $updateLoanQuery = "UPDATE loan SET totalInterest = totalInterest + ? WHERE loanId = ?";
    $updateLoanStmt = mysqli_prepare($con, $updateLoanQuery);
    if (!$updateLoanStmt) {
        throw new Exception("Failed to prepare loan update query: " . mysqli_error($con));
    }

    mysqli_stmt_bind_param($updateLoanStmt, "di", $interestAmount, $loanId);
    if (!mysqli_stmt_execute($updateLoanStmt)) {
        throw new Exception("Failed to update loan interest: " . mysqli_stmt_error($updateLoanStmt));
    }

    // Commit transaction
    mysqli_commit($con);

    // Return success response
    http_response_code(200);
    echo json_encode([
        "status" => "success",
        "message" => "Interest payment deleted successfully"
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
