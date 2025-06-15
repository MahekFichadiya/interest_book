<?php
include "Connection.php";

$json = file_get_contents('php://input');
$data = json_decode($json);

if (!isset($data->loanId) || !is_numeric($data->loanId)) {
    echo json_encode(["error" => "Invalid or missing userId"]);
    http_response_code(400);
    exit;
}

$loanId = intval($data->loanId);

$query = "DELETE FROM loan WHERE loanId = ?";
$stmt = $con->prepare($query);

if (!$stmt) {
    echo json_encode(["error" => "SQL Prepare Failed", "details" => $con->error]);
    http_response_code(500);
    exit;
}

$stmt->bind_param("i", $loanId);
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
