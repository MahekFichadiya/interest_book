<?php
// Simple trigger fix - create a trigger without image column reference
include "Connection.php";

header('Content-Type: text/plain');

try {
    echo "=== Fixing Loan Deletion Trigger ===\n\n";
    
    // Step 1: Drop ALL existing triggers
    echo "1. Dropping all existing triggers...\n";
    $dropQueries = [
        "DROP TRIGGER IF EXISTS backupedLoan",
        "DROP TRIGGER IF EXISTS backup_loan_trigger",
        "DROP TRIGGER IF EXISTS loan_backup_trigger",
        "DROP TRIGGER IF EXISTS loan_delete_trigger",
        "DROP TRIGGER IF EXISTS loan_before_delete",
        "DROP TRIGGER IF EXISTS loan_after_delete"
    ];
    
    foreach ($dropQueries as $query) {
        if (mysqli_query($con, $query)) {
            echo "   ✓ Executed: $query\n";
        } else {
            echo "   ⚠ Warning: $query - " . mysqli_error($con) . "\n";
        }
    }
    
    // Step 2: Check table structures
    echo "\n2. Checking table structures...\n";
    
    // Check loan table
    $loanResult = mysqli_query($con, "DESCRIBE loan");
    $loanColumns = [];
    while ($row = mysqli_fetch_assoc($loanResult)) {
        $loanColumns[] = $row['Field'];
    }
    echo "   Loan table columns: " . implode(', ', $loanColumns) . "\n";
    
    // Check historyloan table
    $historyResult = mysqli_query($con, "DESCRIBE historyloan");
    $historyColumns = [];
    while ($row = mysqli_fetch_assoc($historyResult)) {
        $historyColumns[] = $row['Field'];
    }
    echo "   History table columns: " . implode(', ', $historyColumns) . "\n";
    
    // Step 3: Create simple trigger without image column
    echo "\n3. Creating new trigger without image column...\n";
    
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
        
        -- Insert into historyloan WITHOUT image field
        INSERT INTO historyloan (
            loanId, amount, rate, startDate, endDate, note, 
            updatedAmount, type, userId, custId, custName, paymentMode
        )
        VALUES (
            OLD.loanId, OLD.amount, OLD.rate, OLD.startDate, OLD.endDate, OLD.note,
            OLD.updatedAmount, OLD.type, OLD.userId, OLD.custId, customer_name, 
            COALESCE(OLD.paymentMode, 'cash')
        );
        
        -- Archive loan documents
        INSERT INTO history_loan_documents (loanId, documentPath, archivedDate)
        SELECT OLD.loanId, documentPath, NOW()
        FROM loan_documents 
        WHERE loanId = OLD.loanId;
        
        -- Delete loan documents
        DELETE FROM loan_documents WHERE loanId = OLD.loanId;
    END
    ";
    
    if (mysqli_query($con, $createTriggerQuery)) {
        echo "   ✓ New trigger created successfully!\n";
    } else {
        throw new Exception("Failed to create trigger: " . mysqli_error($con));
    }
    
    // Step 4: Verify the trigger
    echo "\n4. Verifying trigger...\n";
    $verifyResult = mysqli_query($con, "SHOW TRIGGERS LIKE 'loan'");
    if ($verifyResult && mysqli_num_rows($verifyResult) > 0) {
        while ($trigger = mysqli_fetch_assoc($verifyResult)) {
            echo "   ✓ Trigger: " . $trigger['Trigger'] . " - " . $trigger['Timing'] . " " . $trigger['Event'] . "\n";
        }
    } else {
        echo "   ⚠ No triggers found for loan table\n";
    }
    
    echo "\n✅ SUCCESS: Loan deletion trigger has been fixed!\n";
    echo "The trigger now works without referencing the image column.\n";
    echo "You can now try deleting loans again.\n";
    
} catch (Exception $e) {
    echo "\n❌ ERROR: " . $e->getMessage() . "\n";
    http_response_code(500);
}

mysqli_close($con);
?>
