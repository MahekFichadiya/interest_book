<?php
include "Connection.php";

// Start transaction for data consistency
mysqli_autocommit($con, FALSE);

try {
    $json = file_get_contents('php://input');
    $data = json_decode($json);

    if (!isset($data->custId) || !is_numeric($data->custId)) {
        throw new Exception("Invalid or missing custId");
    }

    $custId = intval($data->custId);

    // Get all loan IDs for this customer to track what will be deleted
    $getLoanIdsQuery = "SELECT loanId FROM loan WHERE custId = ?";
    $getLoanIdsStmt = mysqli_prepare($con, $getLoanIdsQuery);
    if (!$getLoanIdsStmt) {
        throw new Exception("Failed to prepare get loan IDs query: " . mysqli_error($con));
    }

    mysqli_stmt_bind_param($getLoanIdsStmt, "i", $custId);
    mysqli_stmt_execute($getLoanIdsStmt);
    $loanIdsResult = mysqli_stmt_get_result($getLoanIdsStmt);

    $loanIds = [];
    while ($row = mysqli_fetch_assoc($loanIdsResult)) {
        $loanIds[] = $row['loanId'];
    }

    $deletedLoans = count($loanIds);
    $deletedInterests = 0;
    $deletedDeposits = 0;

    // Step 1: Delete all interest records for loans belonging to this customer
    if (!empty($loanIds)) {
        $loanIdsList = implode(',', array_map('intval', $loanIds));

        // Count interests before deletion
        $countInterestsQuery = "SELECT COUNT(*) as count FROM interest WHERE loanId IN ($loanIdsList)";
        $countInterestsResult = mysqli_query($con, $countInterestsQuery);
        $deletedInterests = mysqli_fetch_assoc($countInterestsResult)['count'];

        // Delete interests
        $deleteInterestsQuery = "DELETE FROM interest WHERE loanId IN ($loanIdsList)";
        if (!mysqli_query($con, $deleteInterestsQuery)) {
            throw new Exception("Failed to delete interest records: " . mysqli_error($con));
        }
    }

    // Step 2: Delete all deposit records for loans belonging to this customer
    if (!empty($loanIds)) {
        // Count deposits before deletion
        $countDepositsQuery = "SELECT COUNT(*) as count FROM deposite WHERE loanid IN ($loanIdsList)";
        $countDepositsResult = mysqli_query($con, $countDepositsQuery);
        $deletedDeposits = mysqli_fetch_assoc($countDepositsResult)['count'];

        // Delete deposits
        $deleteDepositsQuery = "DELETE FROM deposite WHERE loanid IN ($loanIdsList)";
        if (!mysqli_query($con, $deleteDepositsQuery)) {
            throw new Exception("Failed to delete deposit records: " . mysqli_error($con));
        }
    }

    // Step 3: Delete all loans for this customer
    $deleteLoansQuery = "DELETE FROM loan WHERE custId = ?";
    $deleteLoansStmt = mysqli_prepare($con, $deleteLoansQuery);
    if (!$deleteLoansStmt) {
        throw new Exception("Failed to prepare delete loans query: " . mysqli_error($con));
    }

    mysqli_stmt_bind_param($deleteLoansStmt, "i", $custId);
    if (!mysqli_stmt_execute($deleteLoansStmt)) {
        throw new Exception("Failed to delete loan records: " . mysqli_stmt_error($deleteLoansStmt));
    }

    // Step 4: Finally, delete the customer record (this will trigger the backup to historycustomer)
    $deleteCustomerQuery = "DELETE FROM customer WHERE custId = ?";
    $deleteCustomerStmt = mysqli_prepare($con, $deleteCustomerQuery);
    if (!$deleteCustomerStmt) {
        throw new Exception("Failed to prepare delete customer query: " . mysqli_error($con));
    }

    mysqli_stmt_bind_param($deleteCustomerStmt, "i", $custId);
    if (!mysqli_stmt_execute($deleteCustomerStmt)) {
        throw new Exception("Failed to delete customer: " . mysqli_stmt_error($deleteCustomerStmt));
    }

    // Check if customer was actually deleted
    if (mysqli_stmt_affected_rows($deleteCustomerStmt) === 0) {
        throw new Exception("Customer not found or already deleted");
    }

    // Commit transaction
    mysqli_commit($con);

    // Return success response with deletion summary
    http_response_code(200);
    echo json_encode([
        "status" => "success",
        "message" => "Customer and all related data deleted successfully",
        "summary" => [
            "customer_deleted" => 1,
            "loans_deleted" => $deletedLoans,
            "interests_deleted" => $deletedInterests,
            "deposits_deleted" => $deletedDeposits
        ]
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
    mysqli_close($con);
}
