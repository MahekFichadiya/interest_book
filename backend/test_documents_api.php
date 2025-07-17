<?php
// Test file to check if the documents API is working
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Check if this file is accessible
echo json_encode([
    "status" => "true",
    "message" => "Documents API test endpoint is accessible!",
    "server_info" => [
        "php_version" => phpversion(),
        "server_software" => $_SERVER['SERVER_SOFTWARE'] ?? 'Unknown',
        "document_root" => $_SERVER['DOCUMENT_ROOT'] ?? 'Unknown',
        "script_name" => $_SERVER['SCRIPT_NAME'] ?? 'Unknown',
        "request_uri" => $_SERVER['REQUEST_URI'] ?? 'Unknown',
        "current_directory" => __DIR__
    ],
    "request_params" => [
        "GET" => $_GET,
        "POST" => $_POST
    ],
    "files_in_directory" => array_slice(scandir(__DIR__), 2, 10), // Show first 10 files
    "connection_file_exists" => file_exists(__DIR__ . '/Connection.php'),
    "getLoanDocuments_exists" => file_exists(__DIR__ . '/getLoanDocuments.php'),
    "timestamp" => date('Y-m-d H:i:s')
]);
?>
