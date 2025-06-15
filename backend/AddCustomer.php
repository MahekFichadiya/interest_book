<?php

include("Connection.php");

$json = file_get_contents("php://input");
$data = json_decode($json);

$custName = $data->custName;
$custPhn = $data->custPhn;
$custAddress = $data->custAddress;
$date = $data->date;
$userId = $data->userId;

$query = "insert into customer (custName,custPhn,custAddress,date,userID) values ('$custName','$custPhn','$custAddress','$date','$userId')";
$result = mysqli_query($con, $query);

if ($result) {
    // Get the newly created customer ID
    $newCustId = mysqli_insert_id($con);

    // Return the complete customer data
    $response = [
        "status" => true,
        "message" => "Customer added successfully",
        "data" => [
            "custId" => $newCustId,
            "custName" => $custName,
            "custPhn" => $custPhn,
            "custAddress" => $custAddress,
            "date" => $date,
            "userId" => $userId
        ]
    ];

    http_response_code(200);
    echo json_encode($response);
} else {
    http_response_code(400);
    $response = [
        "status" => false,
        "message" => "Failed to add customer",
        "error" => mysqli_error($con)
    ];
    echo json_encode($response);
}

?>