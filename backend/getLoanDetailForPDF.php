<?php
include("connection.php");

// Fetch custId and userId from the request
$custId = $_GET['custId'];
$userId = $_GET['userId'];

// Prepare the query to get all loans for this userId and custId
$stmt = $con->prepare("
    SELECT 
        l.loanId,
        l.startDate,
        l.endDate,
        IF(l.endDate IS NULL, 
            TIMESTAMPDIFF(MONTH, l.startDate, NOW()), 
            TIMESTAMPDIFF(MONTH, l.startDate, l.endDate)
        ) AS duration,
        l.amount,
        l.note AS loanNote,

        -- Deposit details
        (SELECT GROUP_CONCAT(CONCAT('Amount: ', d.depositeAmount, ', Date: ', d.depositeDate, ', Note: ', d.depositeNote) SEPARATOR ' | ')
         FROM deposite d
         WHERE d.loanid = l.loanId) AS deposit_details,

        -- Interest details
        (SELECT GROUP_CONCAT(CONCAT('Amount: ', i.interestAmount, ', Date: ', i.interestDate, ', Note: ', i.interestNote) SEPARATOR ' | ')
         FROM interest i
         WHERE i.loanId = l.loanId) AS interest_details

    FROM 
        loan l
    WHERE 
        l.userId = ? AND l.custId = ?
");

// Bind parameters
$stmt->bind_param("ii", $userId, $custId);
$stmt->execute();

// Fetch all loan rows
$result = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);

// Output the result as JSON
header('Content-Type: application/json');
echo json_encode($result, JSON_PRETTY_PRINT);


?>