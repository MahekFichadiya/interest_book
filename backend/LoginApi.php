<?php

include "Connection.php";

$json = file_get_contents('php://input');
$data = json_decode($json);

$email = $data->email;
$password = $data->password;

$query = "select * from user where email = '$email' and password = '$password' ";
$result = mysqli_query($con, $query);
$count = mysqli_num_rows($result);
if ($count == 1) {
    $rec = mysqli_fetch_assoc($result);
    $response = [
        "status" => true,
        "message" => "user data",
        "data" => $rec
    ];
    echo json_encode($response);
} else {
    http_response_code(404);
    $response = [
        "status" => false,
        "message" => "No user found"
    ];
    echo json_encode($response);
}

?>