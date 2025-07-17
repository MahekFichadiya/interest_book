<?php
// Migrate Single Image to Multiple Documents System
// This script transfers existing single images from loan.image field to loan_documents table
// and removes the image field from loan table
// Created: 2025-07-05

include("Connection.php");

// Set content type for JSON response
header('Content-Type: application/json');

try {
    // Step 1: Check current loan table structure and image data
    echo "=== MIGRATION START ===\n";
    
    $checkQuery = "SELECT 
        COUNT(*) as TotalLoans,
        SUM(CASE WHEN image IS NOT NULL AND image != '' AND image != 'null' THEN 1 ELSE 0 END) as LoansWithImages,
        SUM(CASE WHEN image IS NULL OR image = '' OR image = 'null' THEN 1 ELSE 0 END) as LoansWithoutImages
    FROM loan";
    
    $result = mysqli_query($con, $checkQuery);
    if (!$result) {
        throw new Exception("Failed to check loan images: " . mysqli_error($con));
    }
    
    $stats = mysqli_fetch_assoc($result);
    echo "Current Status:\n";
    echo "- Total Loans: " . $stats['TotalLoans'] . "\n";
    echo "- Loans with Images: " . $stats['LoansWithImages'] . "\n";
    echo "- Loans without Images: " . $stats['LoansWithoutImages'] . "\n\n";

    // Step 2: Ensure loan_documents table exists
    $createTableQuery = "CREATE TABLE IF NOT EXISTS `loan_documents` (
        `documentId` int(11) NOT NULL AUTO_INCREMENT,
        `loanId` int(5) NOT NULL,
        `documentPath` varchar(255) NOT NULL,
        PRIMARY KEY (`documentId`),
        KEY `fk_loan_documents_loan` (`loanId`),
        CONSTRAINT `fk_loan_documents_loan` FOREIGN KEY (`loanId`) REFERENCES `loan` (`loanId`) ON DELETE CASCADE ON UPDATE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci";
    
    if (!mysqli_query($con, $createTableQuery)) {
        throw new Exception("Failed to create loan_documents table: " . mysqli_error($con));
    }
    echo "✓ loan_documents table ensured\n";

    // Step 3: Check if image field exists in loan table
    $checkImageFieldQuery = "SHOW COLUMNS FROM loan LIKE 'image'";
    $imageFieldResult = mysqli_query($con, $checkImageFieldQuery);
    
    if (mysqli_num_rows($imageFieldResult) == 0) {
        echo "✓ Image field already removed from loan table\n";
        echo "✓ Migration appears to have been run previously\n";
        
        // Show current documents count
        $docCountQuery = "SELECT COUNT(*) as DocumentCount FROM loan_documents";
        $docResult = mysqli_query($con, $docCountQuery);
        $docStats = mysqli_fetch_assoc($docResult);
        echo "✓ Current documents in loan_documents table: " . $docStats['DocumentCount'] . "\n";
        
    } else {
        echo "✓ Image field found, proceeding with migration...\n";
        
        // Step 4: Transfer existing images to loan_documents table
        $transferQuery = "INSERT INTO loan_documents (loanId, documentPath)
            SELECT loanId, image
            FROM loan 
            WHERE image IS NOT NULL 
              AND image != '' 
              AND image != 'null'
              AND loanId NOT IN (
                SELECT DISTINCT loanId 
                FROM loan_documents
              )";
        
        $transferResult = mysqli_query($con, $transferQuery);
        if (!$transferResult) {
            throw new Exception("Failed to transfer images: " . mysqli_error($con));
        }
        
        $transferredCount = mysqli_affected_rows($con);
        echo "✓ Transferred $transferredCount images to loan_documents table\n";

        // Step 5: Verify transfer
        $verifyQuery = "SELECT COUNT(*) as DocumentCount FROM loan_documents";
        $verifyResult = mysqli_query($con, $verifyQuery);
        $verifyStats = mysqli_fetch_assoc($verifyResult);
        echo "✓ Total documents in loan_documents table: " . $verifyStats['DocumentCount'] . "\n";

        // Step 6: Remove image field from loan table
        $removeFieldQuery = "ALTER TABLE loan DROP COLUMN image";
        if (!mysqli_query($con, $removeFieldQuery)) {
            throw new Exception("Failed to remove image field: " . mysqli_error($con));
        }
        echo "✓ Removed image field from loan table\n";
    }

    // Step 7: Show final verification
    $finalQuery = "SELECT 
        l.loanId,
        l.amount,
        l.note,
        COUNT(ld.documentId) as DocumentCount,
        GROUP_CONCAT(ld.documentPath SEPARATOR ', ') as DocumentPaths
    FROM loan l
    LEFT JOIN loan_documents ld ON l.loanId = ld.loanId
    GROUP BY l.loanId, l.amount, l.note
    HAVING DocumentCount > 0
    LIMIT 5";
    
    $finalResult = mysqli_query($con, $finalQuery);
    if ($finalResult && mysqli_num_rows($finalResult) > 0) {
        echo "\nSample loans with documents:\n";
        while ($row = mysqli_fetch_assoc($finalResult)) {
            echo "- Loan ID: " . $row['loanId'] . 
                 ", Amount: " . $row['amount'] . 
                 ", Documents: " . $row['DocumentCount'] . 
                 " (" . $row['DocumentPaths'] . ")\n";
        }
    }

    echo "\n=== MIGRATION COMPLETED SUCCESSFULLY ===\n";
    echo "✓ Database schema updated for multiple documents\n";
    echo "✓ Existing images transferred to loan_documents table\n";
    echo "✓ Ready for backend and frontend updates\n";

    // Return success response
    http_response_code(200);
    echo json_encode([
        "status" => "true",
        "message" => "Migration completed successfully",
        "stats" => $stats,
        "documentsTransferred" => $transferredCount ?? 0
    ]);

} catch (Exception $e) {
    echo "\n=== MIGRATION FAILED ===\n";
    echo "Error: " . $e->getMessage() . "\n";
    
    http_response_code(500);
    echo json_encode([
        "status" => "false",
        "message" => "Migration failed: " . $e->getMessage()
    ]);
}

mysqli_close($con);
?>
