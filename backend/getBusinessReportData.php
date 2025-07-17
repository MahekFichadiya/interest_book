<?php
include("connection.php");

// Get userId from request
$userId = $_GET['userId'] ?? $_POST['userId'] ?? null;

if (!$userId) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "userId is required"
    ]);
    exit;
}

try {
    // Get comprehensive business report data with interest calculations
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
        WHERE
            c.userId = ?
        GROUP BY
            c.custId, c.userId, c.custName, c.date
        ORDER BY
            c.custName ASC
    ");
    
    $stmt->bind_param("i", $userId);
    $stmt->execute();
    $result = $stmt->get_result();
    $customers = $result->fetch_all(MYSQLI_ASSOC);
    
    // Calculate totals
    $totalYouGave = 0;
    $totalYouGot = 0;
    $totalYouGaveInterest = 0;
    $totalYouGotInterest = 0;
    
    foreach ($customers as &$customer) {
        $youGave = floatval($customer['you_gave_amount']);
        $youGot = floatval($customer['you_got_amount']);
        $youGaveInterest = floatval($customer['you_gave_interest']);
        $youGotInterest = floatval($customer['you_got_interest']);
        
        // Add calculated totals to customer data
        $customer['total_you_gave'] = $youGave + $youGaveInterest;
        $customer['total_you_got'] = $youGot + $youGotInterest;
        $customer['balance'] = $customer['total_you_got'] - $customer['total_you_gave'];
        
        // Add to overall totals
        $totalYouGave += $youGave;
        $totalYouGot += $youGot;
        $totalYouGaveInterest += $youGaveInterest;
        $totalYouGotInterest += $youGotInterest;
    }
    
    $grandTotalYouGave = $totalYouGave + $totalYouGaveInterest;
    $grandTotalYouGot = $totalYouGot + $totalYouGotInterest;
    $netBalance = $grandTotalYouGot - $grandTotalYouGave;
    
    // Return comprehensive business report data
    header('Content-Type: application/json');
    echo json_encode([
        "status" => "success",
        "data" => [
            "customers" => $customers,
            "summary" => [
                "total_customers" => count($customers),
                "principal_you_gave" => $totalYouGave,
                "principal_you_got" => $totalYouGot,
                "interest_you_gave" => $totalYouGaveInterest,
                "interest_you_got" => $totalYouGotInterest,
                "total_you_gave" => $grandTotalYouGave,
                "total_you_got" => $grandTotalYouGot,
                "net_balance" => $netBalance,
                "total_interest" => $totalYouGaveInterest + $totalYouGotInterest
            ]
        ]
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Database error: " . $e->getMessage()
    ]);
}

$con->close();
