<?php

// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Set headers for CORS and JSON response
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

include "Connection.php";

// Check database connection
if (!$con) {
    http_response_code(500);
    echo json_encode([
        "status" => false,
        "message" => "Database connection failed: " . mysqli_connect_error()
    ]);
    exit;
}

$json = file_get_contents('php://input');
$data = json_decode($json);

// Validate input data
if (!$data) {
    http_response_code(400);
    echo json_encode([
        "status" => false,
        "message" => "Invalid request data"
    ]);
    exit;
}

// Check for missing email
if (!isset($data->email) || empty(trim($data->email))) {
    http_response_code(400);
    echo json_encode([
        "status" => false,
        "message" => "Email is required"
    ]);
    exit;
}

// Check for missing password
if (!isset($data->password) || empty($data->password)) {
    http_response_code(400);
    echo json_encode([
        "status" => false,
        "message" => "Password is required"
    ]);
    exit;
}

$email = trim($data->email);
$password = $data->password;

// Validate email format
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode([
        "status" => false,
        "message" => "Please enter a valid email address"
    ]);
    exit;
}

// Get user data using prepared statement
$query = "SELECT * FROM user WHERE email = ?";
$stmt = mysqli_prepare($con, $query);

if (!$stmt) {
    http_response_code(500);
    echo json_encode([
        "status" => false,
        "message" => "Database error: " . mysqli_error($con)
    ]);
    exit;
}

mysqli_stmt_bind_param($stmt, "s", $email);
mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);

if (mysqli_num_rows($result) == 1) {
    $user = mysqli_fetch_assoc($result);

    // Verify password using password_verify()
    if (password_verify($password, $user['password'])) {
        // Remove password from response for security
        unset($user['password']);

        $response = [
            "status" => true,
            "message" => "Login successful",
            "data" => $user
        ];
        echo json_encode($response);
        http_response_code(200);
    } else {
        http_response_code(401);
        $response = [
            "status" => false,
            "message" => "Invalid password"
        ];
        echo json_encode($response);
    }
} else {
    http_response_code(404);
    $response = [
        "status" => false,
        "message" => "User not found"
    ];
    echo json_encode($response);
}

mysqli_stmt_close($stmt);
mysqli_close($con);

?>