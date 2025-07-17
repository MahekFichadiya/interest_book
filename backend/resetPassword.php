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

// Set timezone to ensure consistency
date_default_timezone_set('Asia/Kolkata'); // Change this to your timezone

// Get JSON input
$json = file_get_contents('php://input');
$data = json_decode($json);

// Log the received data for debugging
error_log("Reset password received data: " . $json);

// Validate JSON parsing
if (json_last_error() !== JSON_ERROR_NONE) {
    http_response_code(400);
    echo json_encode([
        "status" => false,
        "message" => "Invalid JSON format"
    ]);
    exit;
}

// Validate input
if (!isset($data->email) || empty($data->email) || !isset($data->newPassword) || empty($data->newPassword)) {
    http_response_code(400);
    echo json_encode([
        "status" => false,
        "message" => "Email and new password are required"
    ]);
    exit;
}

$email = mysqli_real_escape_string($con, $data->email);
$newPassword = mysqli_real_escape_string($con, $data->newPassword);

// Validate email format
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode([
        "status" => false,
        "message" => "Invalid email format"
    ]);
    exit;
}

// Validate password length (5-8 characters as per existing validation)
if (strlen($newPassword) < 5 || strlen($newPassword) > 8) {
    http_response_code(400);
    echo json_encode([
        "status" => false,
        "message" => "Password length should be 5 to 8 characters"
    ]);
    exit;
}

// Check if user exists using prepared statement
$userQuery = "SELECT * FROM user WHERE email = ?";
$userStmt = mysqli_prepare($con, $userQuery);

if (!$userStmt) {
    http_response_code(500);
    echo json_encode([
        "status" => false,
        "message" => "Database error: " . mysqli_error($con)
    ]);
    exit;
}

mysqli_stmt_bind_param($userStmt, "s", $email);
mysqli_stmt_execute($userStmt);
$userResult = mysqli_stmt_get_result($userStmt);

if (mysqli_num_rows($userResult) == 0) {
    mysqli_stmt_close($userStmt);
    http_response_code(404);
    echo json_encode([
        "status" => false,
        "message" => "User not found"
    ]);
    exit;
}

mysqli_stmt_close($userStmt);

// Check if there's a recent verified OTP for this email (within last 30 minutes)
$otpQuery = "SELECT * FROM otp_verification WHERE email = ? AND is_used = 1 AND created_at > DATE_SUB(NOW(), INTERVAL 30 MINUTE) ORDER BY created_at DESC LIMIT 1";
$otpStmt = mysqli_prepare($con, $otpQuery);

if (!$otpStmt) {
    http_response_code(500);
    echo json_encode([
        "status" => false,
        "message" => "Database error: " . mysqli_error($con)
    ]);
    exit;
}

mysqli_stmt_bind_param($otpStmt, "s", $email);
mysqli_stmt_execute($otpStmt);
$otpResult = mysqli_stmt_get_result($otpStmt);

if (mysqli_num_rows($otpResult) == 0) {
    mysqli_stmt_close($otpStmt);
    http_response_code(403);
    echo json_encode([
        "status" => false,
        "message" => "No valid OTP verification found. Please verify OTP first."
    ]);
    exit;
}

mysqli_stmt_close($otpStmt);

// Hash the new password securely
$hashedPassword = password_hash($newPassword, PASSWORD_DEFAULT);

// Update user password using prepared statement
$updateQuery = "UPDATE user SET password = ? WHERE email = ?";
$updateStmt = mysqli_prepare($con, $updateQuery);

if (!$updateStmt) {
    http_response_code(500);
    echo json_encode([
        "status" => false,
        "message" => "Database error: " . mysqli_error($con)
    ]);
    exit;
}

mysqli_stmt_bind_param($updateStmt, "ss", $hashedPassword, $email);
$updateResult = mysqli_stmt_execute($updateStmt);

if ($updateResult) {
    // Clean up used OTP records for this email
    $cleanupQuery = "DELETE FROM otp_verification WHERE email = ?";
    $cleanupStmt = mysqli_prepare($con, $cleanupQuery);
    if ($cleanupStmt) {
        mysqli_stmt_bind_param($cleanupStmt, "s", $email);
        mysqli_stmt_execute($cleanupStmt);
        mysqli_stmt_close($cleanupStmt);
    }

    mysqli_stmt_close($updateStmt);

    echo json_encode([
        "status" => true,
        "message" => "Password reset successfully"
    ]);
} else {
    http_response_code(500);
    echo json_encode([
        "status" => false,
        "message" => "Failed to reset password: " . mysqli_stmt_error($updateStmt)
    ]);
    mysqli_stmt_close($updateStmt);
}

mysqli_close($con);

?>
