<?php
include "Connection.php";

header('Content-Type: text/plain');

try {
    echo "=== Preventing Duplicate Settled Customers ===\n\n";
    
    // Step 1: Drop the existing trigger
    echo "1. Dropping existing backupedCustomer trigger...\n";
    $result = mysqli_query($con, "DROP TRIGGER IF EXISTS `backupedCustomer`");
    if ($result) {
        echo "   ✅ Existing trigger dropped successfully\n";
    } else {
        echo "   ⚠️ Warning: " . mysqli_error($con) . "\n";
    }
    
    // Step 2: Create the new trigger with duplicate prevention
    echo "\n2. Creating new backupedCustomer trigger with duplicate prevention...\n";
    $createTriggerQuery = "
    CREATE TRIGGER `backupedCustomer` AFTER DELETE ON `customer` FOR EACH ROW 
    BEGIN
        DECLARE existing_count INT DEFAULT 0;
        
        -- Check if a customer with the same name and mobile number already exists in historycustomer
        SELECT COUNT(*) INTO existing_count
        FROM historycustomer 
        WHERE custName = OLD.custName 
        AND custPhn = OLD.custPhn 
        AND userId = OLD.userId;
        
        -- Only insert if no duplicate exists
        IF existing_count = 0 THEN
            INSERT INTO historycustomer (custId, custName, custPhn, custAddress, custPic, date, userId)
            VALUES (OLD.custId, OLD.custName, OLD.custPhn, OLD.custAddress, OLD.custPic, OLD.date, OLD.userId);
        END IF;
    END
    ";
    
    $result = mysqli_query($con, $createTriggerQuery);
    if ($result) {
        echo "   ✅ New trigger created successfully\n";
    } else {
        echo "   ❌ Error creating trigger: " . mysqli_error($con) . "\n";
        throw new Exception("Failed to create trigger");
    }
    
    // Step 3: Check for existing duplicates
    echo "\n3. Checking for existing duplicates...\n";
    $duplicateCheckQuery = "
    SELECT 
        custName, 
        custPhn, 
        userId,
        COUNT(*) as count,
        GROUP_CONCAT(custId ORDER BY custId) as customer_ids
    FROM historycustomer 
    GROUP BY custName, custPhn, userId
    HAVING COUNT(*) > 1
    ORDER BY custName, custPhn
    ";
    
    $result = mysqli_query($con, $duplicateCheckQuery);
    if ($result) {
        $duplicateCount = mysqli_num_rows($result);
        if ($duplicateCount > 0) {
            echo "   ⚠️ Found $duplicateCount duplicate groups:\n";
            while ($row = mysqli_fetch_assoc($result)) {
                echo "      - {$row['custName']} ({$row['custPhn']}) - {$row['count']} entries (IDs: {$row['customer_ids']})\n";
            }
        } else {
            echo "   ✅ No duplicates found\n";
        }
    }
    
    // Step 4: Clean up duplicates (keep the most recent entry)
    if ($duplicateCount > 0) {
        echo "\n4. Cleaning up duplicates (keeping most recent entry for each name+phone combination)...\n";
        $cleanupQuery = "
        DELETE h1 FROM historycustomer h1
        INNER JOIN historycustomer h2 
        WHERE h1.custName = h2.custName 
        AND h1.custPhn = h2.custPhn 
        AND h1.userId = h2.userId
        AND h1.custId < h2.custId
        ";
        
        $result = mysqli_query($con, $cleanupQuery);
        if ($result) {
            $deletedRows = mysqli_affected_rows($con);
            echo "   ✅ Cleaned up $deletedRows duplicate entries\n";
        } else {
            echo "   ❌ Error cleaning up duplicates: " . mysqli_error($con) . "\n";
        }
    }
    
    // Step 5: Final verification
    echo "\n5. Final verification...\n";
    $verificationQuery = "
    SELECT 
        COUNT(*) as total_settled_customers,
        COUNT(DISTINCT CONCAT(custName, '-', custPhn, '-', userId)) as unique_combinations
    FROM historycustomer
    ";
    
    $result = mysqli_query($con, $verificationQuery);
    if ($result) {
        $row = mysqli_fetch_assoc($result);
        $total = $row['total_settled_customers'];
        $unique = $row['unique_combinations'];
        $remaining_duplicates = $total - $unique;
        
        echo "   📊 Total settled customers: $total\n";
        echo "   📊 Unique name+phone combinations: $unique\n";
        echo "   📊 Remaining duplicates: $remaining_duplicates\n";
        
        if ($remaining_duplicates == 0) {
            echo "   ✅ All duplicates have been resolved!\n";
        } else {
            echo "   ⚠️ Some duplicates may still exist\n";
        }
    }
    
    echo "\n✅ Duplicate prevention system is now active!\n";
    echo "\nHow it works:\n";
    echo "- When a customer is deleted, the system checks if a customer with the same name and mobile number already exists in historycustomer\n";
    echo "- If a duplicate exists, the new entry is NOT added to prevent duplicates\n";
    echo "- This ensures each unique name+mobile combination appears only once in settled customers\n";
    
} catch (Exception $e) {
    echo "\n❌ Error: " . $e->getMessage() . "\n";
}

mysqli_close($con);
?>
