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
    // Calculate total amounts based on loan type for the specific user
    $stmt = $con->prepare("
        SELECT 
            SUM(CASE WHEN type = 1 THEN updatedAmount ELSE 0 END) AS you_gave_total,
            SUM(CASE WHEN type = 0 THEN updatedAmount ELSE 0 END) AS you_got_total
        FROM 
            loan 
        WHERE 
            userId = ?
    ");
    
    $stmt->bind_param("i", $userId);
    $stmt->execute();
    $result = $stmt->get_result();
    $data = $result->fetch_assoc();
    
    // Ensure we have numeric values (handle null cases)
    $youGave = floatval($data['you_gave_total'] ?? 0);
    $youGot = floatval($data['you_got_total'] ?? 0);
    
    // Return the result as JSON
    header('Content-Type: application/json');
    echo json_encode([
        "status" => "success",
        "data" => [
            "you_gave" => $youGave,
            "you_got" => $youGot
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
?>
