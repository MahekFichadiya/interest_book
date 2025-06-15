<?php

include("connection.php");

$json = file_get_contents("php://input");
$data = json_decode($json);

$userId = $data->userId;

// Make sure userId is provided
if (!isset($userId)) {
    echo json_encode(["error" => "User ID is required"]);
    exit;
}

// Optional: Get custId if provided (can be null)
$custId = isset($data->custId) ? $data->custId : null;

$response = [];

// Build query
$query = "
    SELECT h.*, c.custName
    FROM historyloan h
    LEFT JOIN customer c ON TRIM(h.custId) = TRIM(c.custId)
    WHERE h.userId = '$userId'
";

if (!empty($custId)) {
    $query .= " AND h.custId = '$custId'";
}

$result = mysqli_query($con, $query);

// Check if query succeeded
if (!$result) {
    echo json_encode(["error" => "Query failed: " . mysqli_error($con)]);
    exit;
}

// Fetch results
while ($row = mysqli_fetch_assoc($result)) {
    $response[] = $row;
}

echo json_encode($response);
