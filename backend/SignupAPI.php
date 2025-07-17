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

include("Connection.php");

// Check database connection
if (!$con) {
    http_response_code(500);
    echo json_encode([
        "status" => false,
        "message" => "Database connection failed: " . mysqli_connect_error()
    ]);
    exit;
}

$json = file_get_contents("php://input");
$data = json_decode($json);

// Validate input data
if (!$data || !isset($data->name) || !isset($data->mobileNo) || !isset($data->email) || !isset($data->password)) {
    http_response_code(400);
    echo json_encode([
        "status" => false,
        "message" => "Missing required fields"
    ]);
    exit;
}

$name = trim($data->name);
$mobileNo = trim($data->mobileNo);
$email = trim($data->email);
$password = $data->password;

// Validate email format
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode([
        "status" => false,
        "message" => "Invalid email format"
    ]);
    exit;
}

// Validate mobile number format (supports both Indian and international formats)
function validateMobileNumber($mobileNo) {
    $mobileNo = trim($mobileNo);

    if (empty($mobileNo)) {
        return "Mobile number required";
    }

    // Check if it's an international format (starts with +)
    if (strpos($mobileNo, '+') === 0) {
        // International format validation: +XX XXXXXXXXXX
        if (!preg_match('/^\+\d{1,4}\s?\d{6,14}$/', $mobileNo)) {
            return "Invalid international format. Use +XX XXXXXXXXXX";
        }
    } else {
        // Indian format validation: 10 digits starting with 6-9
        $cleanMobileNo = preg_replace('/\D/', '', $mobileNo);

        if (strlen($cleanMobileNo) !== 10) {
            return "Must be exactly 10 digits";
        }

        if (!preg_match('/^[6-9]\d{9}$/', $cleanMobileNo)) {
            return "Must start with 6, 7, 8, or 9";
        }

        // Check for all same digits
        if (preg_match('/^(\d)\1{9}$/', $cleanMobileNo)) {
            return "Cannot have all same digits";
        }
    }

    return null; // Valid
}

$mobileValidationError = validateMobileNumber($mobileNo);
if ($mobileValidationError !== null) {
    http_response_code(400);
    echo json_encode([
        "status" => false,
        "message" => $mobileValidationError
    ]);
    exit;
}

// Check if user already exists (by email or mobile number)
// First check email
$checkEmailQuery = "SELECT userId, email FROM user WHERE email = ?";
$checkEmailStmt = mysqli_prepare($con, $checkEmailQuery);

if (!$checkEmailStmt) {
    http_response_code(500);
    echo json_encode([
        "status" => false,
        "message" => "Database error: " . mysqli_error($con)
    ]);
    exit;
}

mysqli_stmt_bind_param($checkEmailStmt, "s", $email);
mysqli_stmt_execute($checkEmailStmt);
$emailResult = mysqli_stmt_get_result($checkEmailStmt);

if (mysqli_num_rows($emailResult) > 0) {
    mysqli_stmt_close($checkEmailStmt);
    http_response_code(409);
    echo json_encode([
        "status" => false,
        "message" => "User with this email already exists"
    ]);
    exit;
}
mysqli_stmt_close($checkEmailStmt);

// Then check mobile number
$checkMobileQuery = "SELECT userId, mobileNo FROM user WHERE mobileNo = ?";
$checkMobileStmt = mysqli_prepare($con, $checkMobileQuery);

if (!$checkMobileStmt) {
    http_response_code(500);
    echo json_encode([
        "status" => false,
        "message" => "Database error: " . mysqli_error($con)
    ]);
    exit;
}

mysqli_stmt_bind_param($checkMobileStmt, "s", $mobileNo);
mysqli_stmt_execute($checkMobileStmt);
$mobileResult = mysqli_stmt_get_result($checkMobileStmt);

if (mysqli_num_rows($mobileResult) > 0) {
    mysqli_stmt_close($checkMobileStmt);
    http_response_code(409);
    echo json_encode([
        "status" => false,
        "message" => "User with this phone number already exists"
    ]);
    exit;
}
mysqli_stmt_close($checkMobileStmt);

// Hash the password securely
$hashedPassword = password_hash($password, PASSWORD_DEFAULT);

// Insert new user using prepared statement
$insertQuery = "INSERT INTO user (name, mobileNo, email, password) VALUES (?, ?, ?, ?)";
$insertStmt = mysqli_prepare($con, $insertQuery);

if (!$insertStmt) {
    http_response_code(500);
    echo json_encode([
        "status" => false,
        "message" => "Database error: " . mysqli_error($con)
    ]);
    exit;
}

mysqli_stmt_bind_param($insertStmt, "ssss", $name, $mobileNo, $email, $hashedPassword);
$result = mysqli_stmt_execute($insertStmt);

if ($result) {
    $userId = mysqli_insert_id($con);
    mysqli_stmt_close($insertStmt);

    echo json_encode([
        "status" => true,
        "message" => "User registered successfully",
        "userId" => $userId
    ]);
    http_response_code(201);
} else {
    http_response_code(500);
    echo json_encode([
        "status" => false,
        "message" => "Failed to register user: " . mysqli_stmt_error($insertStmt)
    ]);
    mysqli_stmt_close($insertStmt);
}

mysqli_close($con);

?>
