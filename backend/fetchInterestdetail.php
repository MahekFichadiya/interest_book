<?php
include("connection.php");

$loanId = $_GET['loanId'] ?? null;

if (!$loanId) {
    http_response_code(400);
    echo json_encode(["error" => "loanId missing"]);
    exit;
}

$query = "SELECT * FROM interest WHERE loanId='$loanId'";
$result = mysqli_query($con, $query);
$response = [];

while ($row = mysqli_fetch_assoc($result)) {
    $response[] = $row;
}

echo json_encode($response);
?>
