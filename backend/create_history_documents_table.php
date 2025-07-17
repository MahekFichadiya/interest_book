<?php
// Create missing history_loan_documents table
include "Connection.php";

header('Content-Type: text/plain');

try {
    echo "=== Creating History Loan Documents Table ===\n\n";
    
    // Check if table already exists
    $checkTableQuery = "SHOW TABLES LIKE 'history_loan_documents'";
    $result = mysqli_query($con, $checkTableQuery);
    
    if (mysqli_num_rows($result) > 0) {
        echo "Table 'history_loan_documents' already exists.\n";
    } else {
        echo "Creating 'history_loan_documents' table...\n";
        
        $createTableQuery = "
        CREATE TABLE `history_loan_documents` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `loanId` int(11) NOT NULL,
            `documentPath` varchar(500) NOT NULL,
            `fileName` varchar(255) DEFAULT NULL,
            `archivedDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            KEY `idx_loan_id` (`loanId`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
        ";
        
        if (mysqli_query($con, $createTableQuery)) {
            echo "✅ Table 'history_loan_documents' created successfully!\n";
        } else {
            throw new Exception("Failed to create table: " . mysqli_error($con));
        }
    }
    
    // Check current loan_documents table structure for reference
    echo "\n=== Current loan_documents table structure ===\n";
    $describeQuery = "DESCRIBE loan_documents";
    $result = mysqli_query($con, $describeQuery);
    
    if ($result) {
        while ($row = mysqli_fetch_assoc($result)) {
            echo "{$row['Field']} - {$row['Type']} - {$row['Null']} - {$row['Key']}\n";
        }
    } else {
        echo "loan_documents table doesn't exist or error: " . mysqli_error($con) . "\n";
    }
    
    echo "\n✅ History documents table setup completed!\n";
    
} catch (Exception $e) {
    echo "\n❌ Error: " . $e->getMessage() . "\n";
    http_response_code(500);
}

mysqli_close($con);
?>
