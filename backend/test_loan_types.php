<?php
include("connection.php");

// Test to show loan types for user 10
$userId = 10;

echo "<h2>Loan Types Analysis for User ID: $userId</h2>";

try {
    // Show all loans with their types
    $stmt = $con->prepare("
        SELECT loanId, amount, updatedAmount, type, 
               CASE WHEN type = 1 THEN 'You Gave' ELSE 'You Got' END as meaning
        FROM loan 
        WHERE userId = ? 
        ORDER BY type, loanId
    ");
    
    $stmt->bind_param("i", $userId);
    $stmt->execute();
    $result = $stmt->get_result();
    
    echo "<h3>All Loans:</h3>";
    echo "<table border='1' style='border-collapse: collapse;'>";
    echo "<tr><th>Loan ID</th><th>Original Amount</th><th>Updated Amount</th><th>Type</th><th>Meaning</th></tr>";
    
    $totalYouGave = 0;
    $totalYouGot = 0;
    
    while ($row = $result->fetch_assoc()) {
        echo "<tr>";
        echo "<td>" . $row['loanId'] . "</td>";
        echo "<td>₹" . number_format($row['amount'], 2) . "</td>";
        echo "<td>₹" . number_format($row['updatedAmount'], 2) . "</td>";
        echo "<td>" . $row['type'] . "</td>";
        echo "<td>" . $row['meaning'] . "</td>";
        echo "</tr>";
        
        if ($row['type'] == 1) {
            $totalYouGave += $row['updatedAmount'];
        } else {
            $totalYouGot += $row['updatedAmount'];
        }
    }
    echo "</table>";
    
    echo "<h3>Summary:</h3>";
    echo "<p><strong>You Gave (type=1):</strong> ₹" . number_format($totalYouGave, 2) . "</p>";
    echo "<p><strong>You Got (type=0):</strong> ₹" . number_format($totalYouGot, 2) . "</p>";
    
    // Test the API query
    echo "<h3>API Query Result:</h3>";
    $apiStmt = $con->prepare("
        SELECT 
            SUM(CASE WHEN type = 1 THEN updatedAmount ELSE 0 END) AS you_gave_total,
            SUM(CASE WHEN type = 0 THEN updatedAmount ELSE 0 END) AS you_got_total
        FROM 
            loan 
        WHERE 
            userId = ?
    ");
    
    $apiStmt->bind_param("i", $userId);
    $apiStmt->execute();
    $apiResult = $apiStmt->get_result();
    $apiData = $apiResult->fetch_assoc();
    
    echo "<p><strong>API You Gave:</strong> ₹" . number_format($apiData['you_gave_total'], 2) . "</p>";
    echo "<p><strong>API You Got:</strong> ₹" . number_format($apiData['you_got_total'], 2) . "</p>";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "<br>";
}

$con->close();
?>
