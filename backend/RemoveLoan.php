<?php
include "Connection.php";

// Set content type to JSON
header('Content-Type: application/json');

$json = file_get_contents('php://input');
$data = json_decode($json);

if (!isset($data->loanId) || !is_numeric($data->loanId)) {
    echo json_encode(["error" => "Invalid or missing loanId"]);
    http_response_code(400);
    exit;
}

$loanId = intval($data->loanId);
$confirmCustomerDeletion = isset($data->confirmCustomerDeletion) ? $data->confirmCustomerDeletion : false;
$deleteLoanOnly = isset($data->deleteLoanOnly) ? $data->deleteLoanOnly : false;

try {
    // Start transaction
    mysqli_autocommit($con, FALSE);

    // First, get loan data for backup before deletion
    $getLoanQuery = "SELECT l.*, c.custName FROM loan l
                     LEFT JOIN customer c ON l.custId = c.custId
                     WHERE l.loanId = ?";
    $getLoanStmt = mysqli_prepare($con, $getLoanQuery);
    if (!$getLoanStmt) {
        throw new Exception("Failed to prepare get loan query: " . mysqli_error($con));
    }
    mysqli_stmt_bind_param($getLoanStmt, "i", $loanId);
    if (!mysqli_stmt_execute($getLoanStmt)) {
        throw new Exception("Failed to get loan data: " . mysqli_stmt_error($getLoanStmt));
    }

    $loanResult = mysqli_stmt_get_result($getLoanStmt);
    $loanData = mysqli_fetch_assoc($loanResult);

    if (!$loanData) {
        throw new Exception("Loan not found");
    }

    // COMPLETELY DISABLE TRIGGERS for this session to avoid any trigger issues
    mysqli_query($con, "SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO'");
    mysqli_query($con, "SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0");
    mysqli_query($con, "SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0");

    // Drop ALL possible triggers that might interfere
    $disableTriggerQueries = [
        "DROP TRIGGER IF EXISTS backupedLoan",
        "DROP TRIGGER IF EXISTS backup_loan_trigger",
        "DROP TRIGGER IF EXISTS loan_backup_trigger",
        "DROP TRIGGER IF EXISTS loan_delete_trigger",
        "DROP TRIGGER IF EXISTS loan_before_delete",
        "DROP TRIGGER IF EXISTS loan_after_delete"
    ];

    foreach ($disableTriggerQueries as $disableTriggerQuery) {
        mysqli_query($con, $disableTriggerQuery); // Don't throw error if trigger doesn't exist
    }

    // Check what columns exist in historyloan table
    $historyColumnsResult = mysqli_query($con, "DESCRIBE historyloan");
    $historyColumns = [];
    while ($row = mysqli_fetch_assoc($historyColumnsResult)) {
        $historyColumns[] = $row['Field'];
    }

    // Build backup query dynamically based on existing columns
    $backupFields = [];
    $backupValues = [];
    $backupParams = "";
    $backupData = [];

    // Common fields that should exist
    $commonFields = [
        'loanId' => $loanData['loanId'],
        'amount' => $loanData['amount'],
        'rate' => $loanData['rate'],
        'startDate' => $loanData['startDate'],
        'endDate' => $loanData['endDate'],
        'note' => $loanData['note'],
        'updatedAmount' => $loanData['updatedAmount'],
        'type' => $loanData['type'],
        'userId' => $loanData['userId'],
        'custId' => $loanData['custId']
    ];

    foreach ($commonFields as $field => $value) {
        if (in_array($field, $historyColumns)) {
            $backupFields[] = $field;
            $backupValues[] = "?";
            $backupData[] = $value;
            if ($field == 'loanId' || $field == 'type' || $field == 'userId' || $field == 'custId') {
                $backupParams .= "i";
            } elseif ($field == 'amount' || $field == 'rate' || $field == 'updatedAmount') {
                $backupParams .= "d";
            } else {
                $backupParams .= "s";
            }
        }
    }

    // Add optional fields if they exist
    if (in_array('custName', $historyColumns)) {
        $backupFields[] = 'custName';
        $backupValues[] = "?";
        $backupData[] = isset($loanData['custName']) ? $loanData['custName'] : 'Unknown Customer';
        $backupParams .= "s";
    }

    if (in_array('paymentMode', $historyColumns)) {
        $backupFields[] = 'paymentMode';
        $backupValues[] = "?";
        $backupData[] = isset($loanData['paymentMode']) ? $loanData['paymentMode'] : 'cash';
        $backupParams .= "s";
    }

    $fieldsStr = implode(', ', $backupFields);
    $valuesStr = implode(', ', $backupValues);

    $backupLoanQuery = "INSERT INTO historyloan ($fieldsStr) VALUES ($valuesStr)";

    $backupStmt = mysqli_prepare($con, $backupLoanQuery);
    if (!$backupStmt) {
        throw new Exception("Failed to prepare backup query: " . mysqli_error($con));
    }

    // Bind parameters dynamically
    if (!empty($backupData)) {
        mysqli_stmt_bind_param($backupStmt, $backupParams, ...$backupData);
    }

    if (!mysqli_stmt_execute($backupStmt)) {
        throw new Exception("Failed to backup loan: " . mysqli_stmt_error($backupStmt));
    }

    // Backup loan documents to history (with error handling)
    try {
        // Check if history_loan_documents table exists
        $checkHistoryTableQuery = "SHOW TABLES LIKE 'history_loan_documents'";
        $historyTableResult = mysqli_query($con, $checkHistoryTableQuery);

        if (mysqli_num_rows($historyTableResult) > 0) {
            // Table exists, backup documents
            $backupDocsQuery = "INSERT INTO history_loan_documents (loanId, documentPath, fileName, archivedDate)
                                SELECT loanId, documentPath,
                                       SUBSTRING_INDEX(documentPath, '/', -1) as fileName,
                                       NOW()
                                FROM loan_documents
                                WHERE loanId = ?";
            $backupDocsStmt = mysqli_prepare($con, $backupDocsQuery);
            if ($backupDocsStmt) {
                mysqli_stmt_bind_param($backupDocsStmt, "i", $loanId);
                if (!mysqli_stmt_execute($backupDocsStmt)) {
                    error_log("Warning: Failed to backup loan documents: " . mysqli_stmt_error($backupDocsStmt));
                }
            }
        } else {
            error_log("Warning: history_loan_documents table does not exist, skipping document backup");
        }

        // Delete loan documents
        $deleteDocsQuery = "DELETE FROM loan_documents WHERE loanId = ?";
        $deleteDocsStmt = mysqli_prepare($con, $deleteDocsQuery);
        if ($deleteDocsStmt) {
            mysqli_stmt_bind_param($deleteDocsStmt, "i", $loanId);
            if (!mysqli_stmt_execute($deleteDocsStmt)) {
                error_log("Warning: Failed to delete loan documents: " . mysqli_stmt_error($deleteDocsStmt));
            }
        }
    } catch (Exception $docError) {
        error_log("Warning: Document handling error: " . $docError->getMessage());
        // Don't throw exception, just log the error and continue
    }

    // Delete related interest records
    $deleteInterestQuery = "DELETE FROM interest WHERE loanId = ?";
    $interestStmt = mysqli_prepare($con, $deleteInterestQuery);
    if (!$interestStmt) {
        throw new Exception("Failed to prepare interest delete query: " . mysqli_error($con));
    }
    mysqli_stmt_bind_param($interestStmt, "i", $loanId);
    if (!mysqli_stmt_execute($interestStmt)) {
        throw new Exception("Failed to delete interest records: " . mysqli_stmt_error($interestStmt));
    }

    // Delete related deposit records
    $deleteDepositQuery = "DELETE FROM deposite WHERE loanid = ?";
    $depositStmt = mysqli_prepare($con, $deleteDepositQuery);
    if (!$depositStmt) {
        throw new Exception("Failed to prepare deposit delete query: " . mysqli_error($con));
    }
    mysqli_stmt_bind_param($depositStmt, "i", $loanId);
    if (!mysqli_stmt_execute($depositStmt)) {
        throw new Exception("Failed to delete deposit records: " . mysqli_stmt_error($depositStmt));
    }

    // Finally, delete the loan record (no trigger will fire now)
    $deleteLoanQuery = "DELETE FROM loan WHERE loanId = ?";
    $loanStmt = mysqli_prepare($con, $deleteLoanQuery);
    if (!$loanStmt) {
        throw new Exception("Failed to prepare loan delete query: " . mysqli_error($con));
    }
    mysqli_stmt_bind_param($loanStmt, "i", $loanId);
    if (!mysqli_stmt_execute($loanStmt)) {
        throw new Exception("Failed to delete loan: " . mysqli_stmt_error($loanStmt));
    }

    // Check if loan was actually deleted
    if (mysqli_stmt_affected_rows($loanStmt) === 0) {
        throw new Exception("Loan not found or already deleted");
    }

    // Get the customer ID from the deleted loan before we lose the reference
    $getCustomerQuery = "SELECT custId FROM historyloan WHERE loanId = ? LIMIT 1";
    $customerStmt = mysqli_prepare($con, $getCustomerQuery);
    if (!$customerStmt) {
        throw new Exception("Failed to prepare customer query: " . mysqli_error($con));
    }
    mysqli_stmt_bind_param($customerStmt, "i", $loanId);
    if (!mysqli_stmt_execute($customerStmt)) {
        throw new Exception("Failed to get customer ID: " . mysqli_stmt_error($customerStmt));
    }
    $customerResult = mysqli_stmt_get_result($customerStmt);
    $customerData = mysqli_fetch_assoc($customerResult);

    if ($customerData) {
        $custId = $customerData['custId'];

        // Check if this customer has any remaining loans
        $checkRemainingLoansQuery = "SELECT COUNT(*) as loan_count FROM loan WHERE custId = ?";
        $checkLoansStmt = mysqli_prepare($con, $checkRemainingLoansQuery);
        if (!$checkLoansStmt) {
            throw new Exception("Failed to prepare remaining loans query: " . mysqli_error($con));
        }
        mysqli_stmt_bind_param($checkLoansStmt, "i", $custId);
        if (!mysqli_stmt_execute($checkLoansStmt)) {
            throw new Exception("Failed to check remaining loans: " . mysqli_stmt_error($checkLoansStmt));
        }
        $loansResult = mysqli_stmt_get_result($checkLoansStmt);
        $loansData = mysqli_fetch_assoc($loansResult);

        $remainingLoans = $loansData['loan_count'];
        $customerDeleted = false;

        // If no remaining loans, check what user wants to do
        if ($remainingLoans == 0) {
            if ($confirmCustomerDeletion) {
                // User confirmed deletion, proceed with customer deletion
                $deleteCustomerQuery = "DELETE FROM customer WHERE custId = ?";
                $deleteCustomerStmt = mysqli_prepare($con, $deleteCustomerQuery);
                if (!$deleteCustomerStmt) {
                    throw new Exception("Failed to prepare delete customer query: " . mysqli_error($con));
                }
                mysqli_stmt_bind_param($deleteCustomerStmt, "i", $custId);
                if (!mysqli_stmt_execute($deleteCustomerStmt)) {
                    throw new Exception("Failed to delete customer: " . mysqli_stmt_error($deleteCustomerStmt));
                }

                if (mysqli_stmt_affected_rows($deleteCustomerStmt) > 0) {
                    $customerDeleted = true;
                }
            } else if ($deleteLoanOnly) {
                // User wants to delete loan only, keep customer even if no loans remain
                // Do nothing - just proceed with loan deletion, customer stays
            } else {
                // No decision made yet - ask for confirmation
                // Rollback transaction and ask for confirmation
                mysqli_rollback($con);
                echo json_encode([
                    "status" => "confirmation_required",
                    "message" => "This is the last loan for this customer. What would you like to do?",
                    "customer_deletion_required" => true,
                    "customer_id" => $custId,
                    "remaining_loans" => $remainingLoans
                ]);
                exit;
            }
        }

        // Check what columns actually exist before recreating trigger
        $checkLoanColumns = "DESCRIBE loan";
        $loanColumnsResult = mysqli_query($con, $checkLoanColumns);
        $loanColumns = [];
        while ($row = mysqli_fetch_assoc($loanColumnsResult)) {
            $loanColumns[] = $row['Field'];
        }

        $checkHistoryColumns = "DESCRIBE historyloan";
        $historyColumnsResult = mysqli_query($con, $checkHistoryColumns);
        $historyColumns = [];
        while ($row = mysqli_fetch_assoc($historyColumnsResult)) {
            $historyColumns[] = $row['Field'];
        }

        // Build trigger fields dynamically based on what exists
        $triggerFields = [];
        $triggerValues = [];

        $commonFields = ['loanId', 'amount', 'rate', 'startDate', 'endDate', 'note', 'updatedAmount', 'type', 'userId', 'custId'];
        foreach ($commonFields as $field) {
            if (in_array($field, $loanColumns) && in_array($field, $historyColumns)) {
                $triggerFields[] = $field;
                $triggerValues[] = "OLD.$field";
            }
        }

        // Add optional fields if they exist in both tables
        if (in_array('paymentMode', $loanColumns) && in_array('paymentMode', $historyColumns)) {
            $triggerFields[] = 'paymentMode';
            $triggerValues[] = 'COALESCE(OLD.paymentMode, "cash")';
        }

        if (in_array('custName', $historyColumns)) {
            $triggerFields[] = 'custName';
            $triggerValues[] = 'customer_name';
        }

        $fieldsStr = implode(', ', $triggerFields);
        $valuesStr = implode(', ', $triggerValues);

        // Recreate the trigger with dynamic fields
        $createTriggerQuery = "
        CREATE TRIGGER `backupedLoan`
        BEFORE DELETE ON `loan`
        FOR EACH ROW
        BEGIN
            DECLARE customer_name VARCHAR(100) DEFAULT 'Unknown Customer';

            -- Get customer name
            SELECT custName INTO customer_name
            FROM customer
            WHERE custId = OLD.custId
            LIMIT 1;

            -- Insert into historyloan with dynamic fields
            INSERT INTO historyloan ($fieldsStr)
            VALUES ($valuesStr);

            -- Archive and delete loan documents
            INSERT INTO history_loan_documents (loanId, documentPath, archivedDate)
            SELECT OLD.loanId, documentPath, NOW()
            FROM loan_documents
            WHERE loanId = OLD.loanId;

            DELETE FROM loan_documents WHERE loanId = OLD.loanId;
        END
        ";

        if (!mysqli_query($con, $createTriggerQuery)) {
            // Log the error but don't fail the transaction
            error_log("Warning: Failed to recreate trigger: " . mysqli_error($con));
        }

        // Restore SQL settings
        mysqli_query($con, "SET SQL_MODE=@OLD_SQL_MODE");
        mysqli_query($con, "SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS");
        mysqli_query($con, "SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS");

        // Commit transaction
        mysqli_commit($con);

        // Return appropriate message based on what was deleted
        if ($customerDeleted) {
            echo json_encode([
                "status" => "success",
                "message" => "Loan deleted and customer removed",
                "customer_deleted" => true,
                "customer_id" => $custId
            ]);
        } else if ($remainingLoans == 0 && $deleteLoanOnly) {
            echo json_encode([
                "status" => "success",
                "message" => "Loan deleted successfully. Customer kept (no remaining loans)",
                "customer_deleted" => false,
                "remaining_loans" => $remainingLoans
            ]);
        } else {
            echo json_encode([
                "status" => "success",
                "message" => "Loan successfully deleted and moved to history",
                "customer_deleted" => false,
                "remaining_loans" => $remainingLoans
            ]);
        }
    } else {
        // Commit transaction even if we couldn't find customer info
        mysqli_commit($con);

        echo json_encode([
            "status" => "success",
            "message" => "Loan successfully deleted and moved to history"
        ]);
    }

    http_response_code(200);

} catch (Exception $e) {
    // Rollback transaction on error
    mysqli_rollback($con);

    // Restore SQL settings even on error
    mysqli_query($con, "SET SQL_MODE=@OLD_SQL_MODE");
    mysqli_query($con, "SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS");
    mysqli_query($con, "SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS");

    echo json_encode([
        "status" => "error",
        "error" => "Failed to delete loan",
        "details" => $e->getMessage()
    ]);
    http_response_code(500);
} finally {
    // Restore autocommit
    mysqli_autocommit($con, TRUE);

    // Close statements if they exist
    if (isset($interestStmt)) mysqli_stmt_close($interestStmt);
    if (isset($depositStmt)) mysqli_stmt_close($depositStmt);
    if (isset($loanStmt)) mysqli_stmt_close($loanStmt);
}

mysqli_close($con);
