<?php
include("connection.php");

// Enhanced business report with interest calculations
$stmt = $con->prepare("
    SELECT
        c.custName,
        c.date,
        SUM(CASE WHEN l.type = 1 THEN l.updatedAmount ELSE 0 END) AS you_gave_amount,
        SUM(CASE WHEN l.type = 0 THEN l.updatedAmount ELSE 0 END) AS you_got_amount,
        SUM(CASE WHEN l.type = 1 THEN l.totalInterest ELSE 0 END) AS you_gave_interest,
        SUM(CASE WHEN l.type = 0 THEN l.totalInterest ELSE 0 END) AS you_got_interest
    FROM
        customer c
    LEFT JOIN
        loan l ON c.custId = l.custId AND c.userId = l.userId
    GROUP BY
        c.custId, c.userId, c.custName, c.date
");

// Execute the query
$stmt->execute();

// Fetch the result
$result = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);

// Output the result as JSON
header('Content-Type: application/json');
echo json_encode($result, JSON_PRETTY_PRINT);
