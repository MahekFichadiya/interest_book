<?php

header('Content-Type: application/json');
include("connection.php");

$json = file_get_contents("php://input");
$data = json_decode($json);

// Extract fields safely
$custId = $_POST['custId'] ?? $data->custId ?? null;
$custName = $_POST['custName'] ?? $data->custName ?? null;
$custPhn = $_POST['custphn'] ?? $data->custphn ?? null;
$custAddress = $_POST['custAddress'] ?? $data->custAddress ?? null;

// Basic validation
if (!$custId || !$custName || !$custPhn) {
    echo json_encode([
        "status" => false,
        "message" => "Missing required fields"
    ]);
    http_response_code(400);
    exit;
}

// Run update query
$query = "UPDATE customer SET custName='$custName', custPhn='$custPhn', custAddress='$custAddress' WHERE custId='$custId'";
$result = mysqli_query($con, $query);

if ($result) {
    $selectQuery = "SELECT * FROM customer WHERE custId='$custId'";
    $selectResult = mysqli_query($con, $selectQuery);
    $custData = mysqli_fetch_assoc($selectResult);

    echo json_encode([
        "status" => true,
        "message" => "Customer updated successfully",
        "data" => $custData
    ]);
    http_response_code(200);
} else {
    echo json_encode([
        "status" => false,
        "message" => "Update failed",
        "error" => mysqli_error($con)
    ]);
    http_response_code(400);
}
?>
