<?php
// Test script to verify AddCustomer.php functionality
include("Connection.php");

header('Content-Type: application/json');

// Test data
$testData = [
    "custName" => "Test Customer",
    "custPhn" => "1234567890",
    "custAddress" => "Test Address",
    "date" => date('Y-m-d H:i:s'),
    "userId" => "10" // Use your actual user ID
];

try {
    $custName = $testData['custName'];
    $custPhn = $testData['custPhn'];
    $custAddress = $testData['custAddress'];
    $date = $testData['date'];
    $userId = $testData['userId'];

    $query = "insert into customer (custName,custPhn,custAddress,date,userID) values ('$custName','$custPhn','$custAddress','$date','$userId')";
    $result = mysqli_query($con, $query);

    if ($result) {
        // Get the newly created customer ID
        $newCustId = mysqli_insert_id($con);
        
        // Return the complete customer data
        $response = [
            "status" => true,
            "message" => "Test customer added successfully",
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
        echo json_encode($response, JSON_PRETTY_PRINT);
        
        // Clean up - delete the test customer
        $deleteQuery = "DELETE FROM customer WHERE custId = $newCustId";
        mysqli_query($con, $deleteQuery);
        
    } else {
        http_response_code(400);
        $response = [
            "status" => false,
            "message" => "Failed to add test customer",
            "error" => mysqli_error($con)
        ];
        echo json_encode($response, JSON_PRETTY_PRINT);
    }

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => $e->getMessage()
    ], JSON_PRETTY_PRINT);
}

$con->close();
?>
