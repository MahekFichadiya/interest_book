<?php

header('Content-Type: application/json'); // ✅ Important to return JSON

include("connection.php");

// Get raw JSON input
$json = file_get_contents("php://input");
$data = json_decode($json);

// Extract fields
$userId = $data->userId;
$name = $data->name;
$mobileNo = $data->mobileNo;
$email = $data->email;

// Update query
$query = "UPDATE user SET name='$name', mobileNo='$mobileNo', email='$email' WHERE userId='$userId'";
$result = mysqli_query($con, $query);

// Handle result
if ($result) {
    // Fetch updated user data to send back to Flutter
    $selectQuery = "SELECT * FROM user WHERE userId='$userId'";
    $selectResult = mysqli_query($con, $selectQuery);
    $userData = mysqli_fetch_assoc($selectResult);

    echo json_encode([
        "status" => true,
        "message" => "Profile updated successfully",
        "data" => $userData
    ]);
    http_response_code(200);
} else {
    echo json_encode([
        "status" => false,
        "message" => "Update failed",
        "error" => mysqli_error($con)
    ]);
    http_response_code(400);
}
?>