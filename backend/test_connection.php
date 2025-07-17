<?php
// Simple test file to check if backend is accessible
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

echo json_encode([
    "status" => "success",
    "message" => "Backend is accessible!",
    "server_info" => [
        "php_version" => phpversion(),
        "server_software" => $_SERVER['SERVER_SOFTWARE'] ?? 'Unknown',
        "document_root" => $_SERVER['DOCUMENT_ROOT'] ?? 'Unknown',
        "script_name" => $_SERVER['SCRIPT_NAME'] ?? 'Unknown',
        "request_uri" => $_SERVER['REQUEST_URI'] ?? 'Unknown'
    ],
    "timestamp" => date('Y-m-d H:i:s')
]);
?>
