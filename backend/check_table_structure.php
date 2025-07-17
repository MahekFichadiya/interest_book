<?php
include "Connection.php";

header('Content-Type: text/plain');

try {
    echo "=== Checking Table Structures ===\n\n";
    
    // Check historyloan table
    echo "1. HISTORYLOAN TABLE STRUCTURE:\n";
    $result = mysqli_query($con, "DESCRIBE historyloan");
    if ($result) {
        while ($row = mysqli_fetch_assoc($result)) {
            echo "   {$row['Field']} - {$row['Type']} - {$row['Null']} - {$row['Key']}\n";
        }
    } else {
        echo "   Error: " . mysqli_error($con) . "\n";
    }
    
    // Check history_loan_documents table
    echo "\n2. HISTORY_LOAN_DOCUMENTS TABLE STRUCTURE:\n";
    $result = mysqli_query($con, "DESCRIBE history_loan_documents");
    if ($result) {
        while ($row = mysqli_fetch_assoc($result)) {
            echo "   {$row['Field']} - {$row['Type']} - {$row['Null']} - {$row['Key']}\n";
        }
    } else {
        echo "   Error: " . mysqli_error($con) . "\n";
    }
    
    // Check if there are any records in history_loan_documents
    echo "\n3. HISTORY LOAN DOCUMENTS COUNT:\n";
    $result = mysqli_query($con, "SELECT COUNT(*) as count FROM history_loan_documents");
    if ($result) {
        $row = mysqli_fetch_assoc($result);
        echo "   Total documents: {$row['count']}\n";
    }
    
    // Check if there are any records for loan 73
    echo "\n4. DOCUMENTS FOR LOAN 73:\n";
    $result = mysqli_query($con, "SELECT * FROM history_loan_documents WHERE loanId = 73");
    if ($result) {
        $count = mysqli_num_rows($result);
        echo "   Documents for loan 73: $count\n";
        while ($row = mysqli_fetch_assoc($result)) {
            echo "   - ID: {$row['id']}, Path: {$row['documentPath']}, Date: {$row['archivedDate']}\n";
        }
    } else {
        echo "   Error: " . mysqli_error($con) . "\n";
    }
    
    // Check historyloan records
    echo "\n5. HISTORYLOAN RECORDS:\n";
    $result = mysqli_query($con, "SELECT loanId, amount, note FROM historyloan WHERE loanId = 73");
    if ($result) {
        $count = mysqli_num_rows($result);
        echo "   History loans for loan 73: $count\n";
        while ($row = mysqli_fetch_assoc($result)) {
            echo "   - Loan ID: {$row['loanId']}, Amount: {$row['amount']}, Note: {$row['note']}\n";
        }
    } else {
        echo "   Error: " . mysqli_error($con) . "\n";
    }
    
    echo "\n✅ Table structure check completed!\n";
    
} catch (Exception $e) {
    echo "\n❌ Error: " . $e->getMessage() . "\n";
}

mysqli_close($con);
?>
