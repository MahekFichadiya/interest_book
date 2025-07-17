<?php
// Check history table structure
include "Connection.php";

header('Content-Type: text/plain');

try {
    echo "=== Checking History Table Structure ===\n\n";
    
    // Check historyloan table structure
    echo "1. History Loan Table Structure:\n";
    $result = mysqli_query($con, "DESCRIBE historyloan");
    if ($result) {
        while ($row = mysqli_fetch_assoc($result)) {
            echo "   {$row['Field']} - {$row['Type']} - {$row['Null']} - {$row['Key']} - {$row['Default']}\n";
        }
    } else {
        echo "   Error: " . mysqli_error($con) . "\n";
    }
    
    // Check if custName and paymentMode columns exist
    echo "\n2. Checking specific columns:\n";
    $checkColumns = ['custName', 'paymentMode'];
    foreach ($checkColumns as $column) {
        $checkQuery = "SELECT COUNT(*) as exists_col FROM INFORMATION_SCHEMA.COLUMNS 
                       WHERE TABLE_SCHEMA = DATABASE() 
                       AND TABLE_NAME = 'historyloan' 
                       AND COLUMN_NAME = '$column'";
        $result = mysqli_query($con, $checkQuery);
        $exists = mysqli_fetch_assoc($result)['exists_col'] > 0;
        echo "   $column: " . ($exists ? "EXISTS" : "MISSING") . "\n";
    }
    
    // Check current triggers
    echo "\n3. Current Triggers:\n";
    $result = mysqli_query($con, "SHOW TRIGGERS LIKE 'loan'");
    if ($result && mysqli_num_rows($result) > 0) {
        while ($trigger = mysqli_fetch_assoc($result)) {
            echo "   {$trigger['Trigger']} - {$trigger['Timing']} {$trigger['Event']}\n";
        }
    } else {
        echo "   No triggers found\n";
    }
    
    echo "\n✅ Check completed!\n";
    
} catch (Exception $e) {
    echo "\n❌ Error: " . $e->getMessage() . "\n";
}

mysqli_close($con);
?>
