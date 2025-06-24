<?php
include("connection.php");

// // Fix: Use correct column names from your DB
// $stmt = $con->prepare("
//     SELECT 
//         c.custName,
//         c.date,
//         MAX(CASE WHEN l.type = 1 THEN l.totalInterest ELSE NULL END) AS max_interest_type_1,
//         MAX(CASE WHEN l.type = 2 THEN l.totalInterest ELSE NULL END) AS max_interest_type_2
//     FROM 
//         customer c
//     LEFT JOIN 
//         loan l ON c.custId = l.custId
//     GROUP BY 
//         c.custId
// ");

// // Execute the query
// $stmt->execute();

// // Fetch the result
// $result = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);

// // Output or process the result
// foreach ($result as $row) {
//     echo "Customer: " . $row['custName'] . "<br>";
//     echo "Customer Date: " . $row['date'] . "<br>";
//     echo "Max Interest (Type 1): " . $row['max_interest_type_1'] . "<br>";
//     echo "Max Interest (Type 2): " . $row['max_interest_type_2'] . "<br><br>";
// }


// include("connection.php");

// // Fix: Use correct column names from your DB
// $stmt = $con->prepare("
//     SELECT 
//         c.custName,
//         c.date,
//         MAX(CASE WHEN l.type = 1 THEN l.totalInterest ELSE NULL END) AS max_interest_type_1,
//         MAX(CASE WHEN l.type = 2 THEN l.totalInterest ELSE NULL END) AS max_interest_type_2
//     FROM 
//         customer c
//     LEFT JOIN 
//         loan l ON c.custId = l.custId
//     GROUP BY 
//         c.custId
// ");

// // Execute the query
// $stmt->execute();

// // Fetch the result
// $result = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);

// // Output the result as JSON
// header('Content-Type: application/json');
// echo json_encode($result, JSON_PRETTY_PRINT);

include("connection.php");

// Fix: Use correct column names from your DB - Updated to use updatedAmount
$stmt = $con->prepare("
    SELECT
        c.custName,
        c.date,
        SUM(CASE WHEN l.type = 1 THEN l.updatedAmount ELSE 0 END) AS you_gave_amount,
        SUM(CASE WHEN l.type = 0 THEN l.updatedAmount ELSE 0 END) AS you_got_amount
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



?>
