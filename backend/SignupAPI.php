<?php

include("Connection.php");

$json = file_get_contents("php://input");
$data = json_decode($json);

$name = $data->name;
$mobileNo = $data->mobileNo;
$email = $data->email;
$password = $data->password;

$query = "insert into user (name,mobileNo,email,password) values ('$name','$mobileNo','$email','$password')";
$result = mysqli_query($con,$query);
if($result){
    print_r($result);
    http_response_code(200);
}
else{
    http_response_code(400);
    print(mysqli_error($con));
}

?>
