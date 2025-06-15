<?php

include("connection.php");

$json = file_get_contents("php://input");
$data = json_decode($json);

$userId = $data->userId;

$query = "select * from historycustomer where userId='$userId'";
$result = mysqli_query($con,$query);
$response = [];

while ($row = mysqli_fetch_assoc($result)) {
    $data = array();
    $data = $row;
    array_push($response, $data);
}
echo json_encode($response);

?>