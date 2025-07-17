<?php

include "Connection.php";

// Enable CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Only allow POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        "status" => false,
        "message" => "Method not allowed"
    ]);
    exit;
}

// Check database connection first
if (!$con) {
    http_response_code(500);
    echo json_encode([
        "status" => false,
        "message" => "Database connection failed: " . mysqli_connect_error()
    ]);
    exit;
}

// Get JSON input
$json = file_get_contents('php://input');

// Log the received data for debugging
error_log("Verify OTP received data: " . $json);

// Check if we got any data
if (empty($json)) {
    http_response_code(400);
    echo json_encode([
        "status" => false,
        "message" => "No data received"
    ]);
    exit;
}

$data = json_decode($json);

// Validate JSON parsing
if (json_last_error() !== JSON_ERROR_NONE) {
    http_response_code(400);
    echo json_encode([
        "status" => false,
        "message" => "Invalid JSON format: " . json_last_error_msg()
    ]);
    exit;
}

// Validate input
if (!isset($data->email) || empty($data->email) || !isset($data->otp) || empty($data->otp)) {
    http_response_code(400);
    echo json_encode([
        "status" => false,
        "message" => "Email and OTP are required"
    ]);
    exit;
}

$email = mysqli_real_escape_string($con, $data->email);
$otp = mysqli_real_escape_string($con, $data->otp);

// Set timezone to ensure consistency
date_default_timezone_set('Asia/Kolkata'); // Change this to your timezone

// Check if OTP table exists
$tableCheck = mysqli_query($con, "SHOW TABLES LIKE 'otp_verification'");
if (mysqli_num_rows($tableCheck) == 0) {
    http_response_code(500);
    echo json_encode([
        "status" => false,
        "message" => "OTP verification table does not exist. Please run setup script."
    ]);
    exit;
}

// Log current time for debugging
error_log("Verifying OTP at server time: " . date('Y-m-d H:i:s'));
error_log("Email: $email, OTP: $otp");

// Validate email format
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode([
        "status" => false,
        "message" => "Invalid email format"
    ]);
    exit;
}

// First, let's check what OTP records exist for this email
$debugQuery = "SELECT email, otp_code, expires_at, is_used, created_at, NOW() as db_now FROM otp_verification WHERE email = ?";
$debugStmt = mysqli_prepare($con, $debugQuery);
mysqli_stmt_bind_param($debugStmt, "s", $email);
mysqli_stmt_execute($debugStmt);
$debugResult = mysqli_stmt_get_result($debugStmt);

if (mysqli_num_rows($debugResult) > 0) {
    while ($row = mysqli_fetch_assoc($debugResult)) {
        error_log("OTP Record - Email: {$row['email']}, OTP: {$row['otp_code']}, Expires: {$row['expires_at']}, Used: {$row['is_used']}, Created: {$row['created_at']}, Current DB Time: {$row['db_now']}");
    }
} else {
    error_log("No OTP records found for email: $email");
}
mysqli_stmt_close($debugStmt);

// Check if OTP exists and is valid using prepared statement
$otpQuery = "SELECT *, NOW() as db_time FROM otp_verification WHERE email = ? AND otp_code = ? AND is_used = 0 AND expires_at > NOW()";
$otpStmt = mysqli_prepare($con, $otpQuery);

if (!$otpStmt) {
    http_response_code(500);
    echo json_encode([
        "status" => false,
        "message" => "Database error: " . mysqli_error($con)
    ]);
    exit;
}

mysqli_stmt_bind_param($otpStmt, "ss", $email, $otp);
mysqli_stmt_execute($otpStmt);
$otpResult = mysqli_stmt_get_result($otpStmt);

if (mysqli_num_rows($otpResult) == 0) {
    // Check if OTP exists but is expired or used
    $expiredQuery = "SELECT * FROM otp_verification WHERE email = ? AND otp_code = ?";
    $expiredStmt = mysqli_prepare($con, $expiredQuery);
    mysqli_stmt_bind_param($expiredStmt, "ss", $email, $otp);
    mysqli_stmt_execute($expiredStmt);
    $expiredResult = mysqli_stmt_get_result($expiredStmt);

    if (mysqli_num_rows($expiredResult) > 0) {
        $otpRecord = mysqli_fetch_assoc($expiredResult);
        if ($otpRecord['is_used'] == 1) {
            $message = "OTP has already been used";
        } else {
            $message = "OTP has expired";
        }
    } else {
        $message = "Invalid OTP";

        // Increment attempt count
        $incrementQuery = "UPDATE otp_verification SET attempts = attempts + 1 WHERE email = ?";
        $incrementStmt = mysqli_prepare($con, $incrementQuery);
        if ($incrementStmt) {
            mysqli_stmt_bind_param($incrementStmt, "s", $email);
            mysqli_stmt_execute($incrementStmt);
            mysqli_stmt_close($incrementStmt);
        }
    }

    mysqli_stmt_close($expiredStmt);
    mysqli_stmt_close($otpStmt);

    http_response_code(400);
    echo json_encode([
        "status" => false,
        "message" => $message
    ]);
    exit;
}

// Mark OTP as used
$updateQuery = "UPDATE otp_verification SET is_used = 1 WHERE email = ? AND otp_code = ?";
$updateStmt = mysqli_prepare($con, $updateQuery);

if ($updateStmt) {
    mysqli_stmt_bind_param($updateStmt, "ss", $email, $otp);
    $updateResult = mysqli_stmt_execute($updateStmt);

    if ($updateResult) {
        echo json_encode([
            "status" => true,
            "message" => "OTP verified successfully",
            "email" => $email
        ]);
    } else {
        http_response_code(500);
        echo json_encode([
            "status" => false,
            "message" => "Failed to verify OTP: " . mysqli_stmt_error($updateStmt)
        ]);
    }
    mysqli_stmt_close($updateStmt);
} else {
    http_response_code(500);
    echo json_encode([
        "status" => false,
        "message" => "Database error: " . mysqli_error($con)
    ]);
}

mysqli_stmt_close($otpStmt);
mysqli_close($con);

?>
