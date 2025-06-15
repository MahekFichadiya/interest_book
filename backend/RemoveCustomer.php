<?php
include "Connection.php";

$json = file_get_contents('php://input');
$data = json_decode($json);

if (!isset($data->custId) || !is_numeric($data->custId)) {
    echo json_encode(["error" => "Invalid or missing userId"]);
    http_response_code(400);
    exit;
}

$custId = intval($data->custId);

$query = "DELETE FROM customer WHERE custId = ?";
$stmt = $con->prepare($query);

if (!$stmt) {
    echo json_encode(["error" => "SQL Prepare Failed", "details" => $con->error]);
    http_response_code(500);
    exit;
}

$stmt->bind_param("i", $custId);
if ($stmt->execute()) {
    echo json_encode(["message" => "Row successfully deleted"]);
    http_response_code(200);
} else {
    echo json_encode(["error" => "Row not deleted", "details" => $stmt->error]);
    http_response_code(500);
}

$stmt->close();
$con->close();
?>
