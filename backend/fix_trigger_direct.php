<?php
// Direct trigger fix script
include "Connection.php";

header('Content-Type: application/json');

try {
    echo "Starting direct trigger fix...\n";
    
    // Step 1: Drop all existing loan-related triggers
    $dropTriggers = [
        "DROP TRIGGER IF EXISTS backupedLoan",
        "DROP TRIGGER IF EXISTS backup_loan_trigger", 
        "DROP TRIGGER IF EXISTS loan_backup_trigger"
    ];
    
    foreach ($dropTriggers as $dropQuery) {
        if (!mysqli_query($con, $dropQuery)) {
            echo "Warning: " . $dropQuery . " failed: " . mysqli_error($con) . "\n";
        } else {
            echo "Executed: " . $dropQuery . "\n";
        }
    }
    
    // Step 2: Check loan table structure
    $checkLoanStructure = "DESCRIBE loan";
    $result = mysqli_query($con, $checkLoanStructure);
    $loanColumns = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $loanColumns[] = $row['Field'];
    }
    echo "Loan table columns: " . implode(', ', $loanColumns) . "\n";
    
    // Step 3: Check historyloan table structure
    $checkHistoryStructure = "DESCRIBE historyloan";
    $result = mysqli_query($con, $checkHistoryStructure);
    $historyColumns = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $historyColumns[] = $row['Field'];
    }
    echo "History loan table columns: " . implode(', ', $historyColumns) . "\n";
    
    // Step 4: Create new trigger based on actual table structure
    $hasImageInLoan = in_array('image', $loanColumns);
    $hasImageInHistory = in_array('image', $historyColumns);
    
    echo "Image column in loan table: " . ($hasImageInLoan ? "YES" : "NO") . "\n";
    echo "Image column in history table: " . ($hasImageInHistory ? "YES" : "NO") . "\n";
    
    // Build the INSERT statement dynamically
    $loanFields = [];
    $loanValues = [];
    
    // Common fields that should exist
    $commonFields = ['loanId', 'amount', 'rate', 'startDate', 'endDate', 'note', 'updatedAmount', 'type', 'userId', 'custId'];
    
    foreach ($commonFields as $field) {
        if (in_array($field, $loanColumns) && in_array($field, $historyColumns)) {
            $loanFields[] = $field;
            $loanValues[] = "OLD.$field";
        }
    }
    
    // Handle optional fields
    if ($hasImageInLoan && $hasImageInHistory) {
        $loanFields[] = 'image';
        $loanValues[] = 'COALESCE(OLD.image, "")';
    }
    
    if (in_array('paymentMode', $loanColumns) && in_array('paymentMode', $historyColumns)) {
        $loanFields[] = 'paymentMode';
        $loanValues[] = 'COALESCE(OLD.paymentMode, "cash")';
    }
    
    if (in_array('custName', $historyColumns)) {
        $loanFields[] = 'custName';
        $loanValues[] = 'customer_name';
    }
    
    $fieldsStr = implode(', ', $loanFields);
    $valuesStr = implode(', ', $loanValues);
    
    // Step 5: Create the new trigger
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
        
        -- Insert into historyloan with proper fields
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
    
    echo "Creating trigger with query:\n" . $createTriggerQuery . "\n";
    
    if (!mysqli_query($con, $createTriggerQuery)) {
        throw new Exception("Failed to create new trigger: " . mysqli_error($con));
    }
    
    echo "✅ New trigger created successfully!\n";
    
    // Step 6: Verify the trigger was created
    $verifyQuery = "
        SELECT 
            TRIGGER_NAME,
            EVENT_MANIPULATION,
            ACTION_TIMING
        FROM INFORMATION_SCHEMA.TRIGGERS 
        WHERE TRIGGER_SCHEMA = DATABASE() 
        AND TRIGGER_NAME = 'backupedLoan'
    ";
    
    $result = mysqli_query($con, $verifyQuery);
    if ($result && mysqli_num_rows($result) > 0) {
        $trigger = mysqli_fetch_assoc($result);
        echo "Trigger verification: " . $trigger['TRIGGER_NAME'] . " (" . $trigger['ACTION_TIMING'] . " " . $trigger['EVENT_MANIPULATION'] . ")\n";
    } else {
        throw new Exception("Trigger verification failed");
    }
    
    echo "\n✅ Database trigger has been fixed successfully!\n";
    echo "Loan deletion should now work properly.\n";
    
    echo json_encode([
        "status" => "success",
        "message" => "Database trigger fixed successfully",
        "loan_columns" => $loanColumns,
        "history_columns" => $historyColumns,
        "trigger_fields" => $loanFields
    ]);
    
} catch (Exception $e) {
    echo "\n❌ Error: " . $e->getMessage() . "\n";
    echo json_encode([
        "status" => "error",
        "message" => $e->getMessage()
    ]);
    http_response_code(500);
}

mysqli_close($con);
?>
