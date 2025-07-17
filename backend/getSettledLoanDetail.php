<?php

include("Connection.php");

// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Set content type to JSON
header('Content-Type: application/json');

try {
    $json = file_get_contents("php://input");
    $data = json_decode($json);

    // Log the received data for debugging
    error_log("Received data: " . $json);

    // Check if JSON decode was successful
    if ($data === null) {
        echo json_encode(["error" => "Invalid JSON data received"]);
        exit;
    }

    $userId = isset($data->userId) ? $data->userId : null;

    // Make sure userId is provided
    if (!$userId) {
        echo json_encode(["error" => "User ID is required"]);
        exit;
    }

    // Optional: Get custId if provided (can be null)
    $custId = isset($data->custId) ? $data->custId : null;

    $response = [];

    // First check if historyloan table exists
    $tableCheck = "SHOW TABLES LIKE 'historyloan'";
    $tableResult = mysqli_query($con, $tableCheck);

    if (mysqli_num_rows($tableResult) == 0) {
        echo json_encode(["error" => "Table 'historyloan' does not exist"]);
        exit;
    }

    // Build query with proper escaping
    $userId = mysqli_real_escape_string($con, $userId);

    $query = "
        SELECT h.*,
               COALESCE(c.custName, hc.custName, 'Unknown Customer') as custName
        FROM historyloan h
        LEFT JOIN customer c ON TRIM(h.custId) = TRIM(c.custId)
        LEFT JOIN historycustomer hc ON TRIM(h.custId) = TRIM(hc.custId)
        WHERE h.userId = '$userId'
        ORDER BY h.startDate DESC
    ";

    if (!empty($custId)) {
        $custId = mysqli_real_escape_string($con, $custId);
        $query = "
            SELECT h.*,
                   COALESCE(c.custName, hc.custName, 'Unknown Customer') as custName
            FROM historyloan h
            LEFT JOIN customer c ON TRIM(h.custId) = TRIM(c.custId)
            LEFT JOIN historycustomer hc ON TRIM(h.custId) = TRIM(hc.custId)
            WHERE h.userId = '$userId' AND h.custId = '$custId'
            ORDER BY h.startDate DESC
        ";
    }

    // Log the query for debugging
    error_log("Executing query: " . $query);

    $result = mysqli_query($con, $query);

    // Check if query succeeded
    if (!$result) {
        $error = mysqli_error($con);
        error_log("Query failed: " . $error);
        echo json_encode(["error" => "Query failed: " . $error]);
        exit;
    }

    // Fetch results
    while ($row = mysqli_fetch_assoc($result)) {
        $response[] = $row;
    }

    // Log the response for debugging
    error_log("Response count: " . count($response));

    echo json_encode($response);

} catch (Exception $e) {
    error_log("Exception: " . $e->getMessage());
    echo json_encode(["error" => "Server error: " . $e->getMessage()]);
}
