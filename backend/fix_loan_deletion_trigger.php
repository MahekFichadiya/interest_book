<?php
// Fix Loan Deletion Trigger
// This script fixes the loan deletion trigger that's causing the "Unknown column 'image'" error

include "Connection.php";

// Set content type to JSON
header('Content-Type: application/json');

try {
    echo "Starting loan deletion trigger fix...\n";
    
    // Step 1: Check if image column exists in loan table
    $checkColumnQuery = "
        SELECT COUNT(*) as column_exists
        FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
        AND TABLE_NAME = 'loan' 
        AND COLUMN_NAME = 'image'
    ";
    
    $result = mysqli_query($con, $checkColumnQuery);
    $row = mysqli_fetch_assoc($result);
    $imageColumnExists = $row['column_exists'] > 0;
    
    echo "Image column exists in loan table: " . ($imageColumnExists ? "YES" : "NO") . "\n";
    
    // Step 2: Drop the old problematic trigger
    $dropTriggerQuery = "DROP TRIGGER IF EXISTS `backupedLoan`";
    if (!mysqli_query($con, $dropTriggerQuery)) {
        throw new Exception("Failed to drop old trigger: " . mysqli_error($con));
    }
    echo "Old trigger dropped successfully.\n";
    
    // Step 3: Create the correct trigger based on whether image column exists
    if ($imageColumnExists) {
        // Image column exists, include it in the trigger
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
            
            -- Insert into historyloan with image field
            INSERT INTO historyloan (
                loanId, amount, rate, startDate, endDate, image, note, 
                updatedAmount, type, userId, custId
            )
            VALUES (
                OLD.loanId, OLD.amount, OLD.rate, OLD.startDate, OLD.endDate, 
                COALESCE(OLD.image, ''), OLD.note, OLD.updatedAmount, OLD.type, 
                OLD.userId, OLD.custId
            );
            
            -- Archive and delete loan documents
            INSERT INTO `history_loan_documents` (`loanId`, `documentPath`, `archivedDate`)
            SELECT OLD.loanId, `documentPath`, NOW()
            FROM `loan_documents` 
            WHERE `loanId` = OLD.loanId;
            
            DELETE FROM `loan_documents` WHERE `loanId` = OLD.loanId;
        END
        ";
    } else {
        // Image column doesn't exist, exclude it from the trigger
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
            
            -- Insert into historyloan without image field
            INSERT INTO historyloan (
                loanId, amount, rate, startDate, endDate, note, 
                updatedAmount, type, userId, custId
            )
            VALUES (
                OLD.loanId, OLD.amount, OLD.rate, OLD.startDate, OLD.endDate, OLD.note,
                OLD.updatedAmount, OLD.type, OLD.userId, OLD.custId
            );
            
            -- Archive and delete loan documents
            INSERT INTO `history_loan_documents` (`loanId`, `documentPath`, `archivedDate`)
            SELECT OLD.loanId, `documentPath`, NOW()
            FROM `loan_documents` 
            WHERE `loanId` = OLD.loanId;
            
            DELETE FROM `loan_documents` WHERE `loanId` = OLD.loanId;
        END
        ";
    }
    
    if (!mysqli_query($con, $createTriggerQuery)) {
        throw new Exception("Failed to create new trigger: " . mysqli_error($con));
    }
    echo "New trigger created successfully.\n";
    
    // Step 4: Verify the trigger was created
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
    
    echo "\n✅ Loan deletion trigger has been fixed successfully!\n";
    echo "The trigger now properly handles the loan table structure.\n";
    
    echo json_encode([
        "status" => "success",
        "message" => "Loan deletion trigger fixed successfully",
        "image_column_exists" => $imageColumnExists
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
