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

// Include email sender
require_once 'email_sender.php';

// Get JSON input
$json = file_get_contents('php://input');
$data = json_decode($json);

// Log the received data for debugging
error_log("Received data: " . $json);

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
if (!isset($data->email) || empty($data->email)) {
    http_response_code(400);
    echo json_encode([
        "status" => false,
        "message" => "Email is required"
    ]);
    exit;
}

$email = mysqli_real_escape_string($con, $data->email);

// Check if user exists
$userQuery = "SELECT * FROM user WHERE email = '$email'";
$userResult = mysqli_query($con, $userQuery);

if (mysqli_num_rows($userResult) == 0) {
    http_response_code(404);
    echo json_encode([
        "status" => false,
        "message" => "No user found with this email address"
    ]);
    exit;
}

// Validate email format
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode([
        "status" => false,
        "message" => "Invalid email format"
    ]);
    exit;
}

// Set timezone to ensure consistency
date_default_timezone_set('Asia/Kolkata'); // Change this to your timezone

// Generate 6-digit OTP
$otp = sprintf("%06d", mt_rand(100000, 999999));

// Set expiration time (15 minutes from now for better testing)
$expiresAt = date('Y-m-d H:i:s', strtotime('+15 minutes'));

// Log current time and expiry for debugging
error_log("Current server time: " . date('Y-m-d H:i:s'));
error_log("OTP expires at: " . $expiresAt);

// Delete any existing OTP for this email
$deleteQuery = "DELETE FROM otp_verification WHERE email = ?";
$deleteStmt = mysqli_prepare($con, $deleteQuery);
if ($deleteStmt) {
    mysqli_stmt_bind_param($deleteStmt, "s", $email);
    mysqli_stmt_execute($deleteStmt);
    mysqli_stmt_close($deleteStmt);
}

// Insert new OTP using prepared statement
$insertQuery = "INSERT INTO otp_verification (email, otp_code, expires_at) VALUES (?, ?, ?)";
$insertStmt = mysqli_prepare($con, $insertQuery);

if ($insertStmt) {
    mysqli_stmt_bind_param($insertStmt, "sss", $email, $otp, $expiresAt);
    $insertResult = mysqli_stmt_execute($insertStmt);

    if ($insertResult) {
        // Send OTP via email using PHPMailer
        $emailResult = sendOTPEmail($email, $otp);

        if ($emailResult['success']) {
            echo json_encode([
                "status" => true,
                "message" => "OTP sent successfully to your email",
                "otp" => $otp, // Remove this line in production
                "expires_in_minutes" => 15,
                "email_status" => "sent",
                "debug_info" => [
                    "email" => $email,
                    "expires_at" => $expiresAt
                ]
            ]);
        } else {
            // Email failed but OTP is stored in database
            echo json_encode([
                "status" => true,
                "message" => "OTP generated but email sending failed. Check server logs for OTP.",
                "otp" => $otp, // Keep this for debugging when email fails
                "expires_in_minutes" => 15,
                "email_status" => "failed",
                "email_error" => $emailResult['message'],
                "debug_info" => [
                    "email" => $email,
                    "expires_at" => $expiresAt
                ]
            ]);
        }
    } else {
        http_response_code(500);
        echo json_encode([
            "status" => false,
            "message" => "Failed to generate OTP: " . mysqli_stmt_error($insertStmt)
        ]);
    }
    mysqli_stmt_close($insertStmt);
} else {
    http_response_code(500);
    echo json_encode([
        "status" => false,
        "message" => "Database error: " . mysqli_error($con)
    ]);
}

mysqli_close($con);

?>
