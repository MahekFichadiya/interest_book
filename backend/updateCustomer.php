<?php

header('Content-Type: application/json');
include("connection.php");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Handle both JSON and form data
    if (isset($_POST['custId'])) {
        // Form data (with file upload)
        $custId = $_POST['custId'];
        $custName = $_POST['custName'];
        $custPhn = $_POST['custphn'];
        $custAddress = $_POST['custAddress'];
    } else {
        // JSON data (without file upload)
        $json = file_get_contents("php://input");
        $data = json_decode($json);
        $custId = $data->custId ?? null;
        $custName = $data->custName ?? null;
        $custPhn = $data->custphn ?? null;
        $custAddress = $data->custAddress ?? null;
    }

    // Handle customer picture upload
    $custPic = null;
    if (isset($_FILES['custPic']) && $_FILES['custPic']['error'] == 0) {
        $uploadDir = "OmJavellerssHTML/CustomerImages/";
        $uploadPath = $_SERVER['DOCUMENT_ROOT'] . '/' . $uploadDir;

        if (!file_exists($uploadPath)) {
            if (!mkdir($uploadPath, 0777, true)) {
                echo json_encode(["status" => false, "message" => "Failed to create directory: $uploadPath"]);
                http_response_code(500);
                exit;
            }
        }

        $fileName = basename($_FILES['custPic']['name']);
        $targetFilePath = $uploadPath . $fileName;

        // Check if image already exists in the CustomerImages folder
        if (file_exists($targetFilePath)) {
            // Image already exists, just use the existing path
            $custPic = $uploadDir . $fileName;
        } else {
            // Image doesn't exist, save the new image
            $custPic = $uploadDir . $fileName;
            if (!move_uploaded_file($_FILES['custPic']['tmp_name'], $targetFilePath)) {
                $custPic = null;
            }
        }
    }

// Basic validation
if (!$custId || !$custName || !$custPhn) {
    echo json_encode([
        "status" => false,
        "message" => "Missing required fields"
    ]);
    http_response_code(400);
    exit;
}

// Run update query
if ($custPic !== null) {
    // Update with new picture
    $query = "UPDATE customer SET custName='$custName', custPhn='$custPhn', custAddress='$custAddress', custPic='$custPic' WHERE custId='$custId'";
} else {
    // Update without changing picture
    $query = "UPDATE customer SET custName='$custName', custPhn='$custPhn', custAddress='$custAddress' WHERE custId='$custId'";
}
$result = mysqli_query($con, $query);

if ($result) {
    $selectQuery = "SELECT * FROM customer WHERE custId='$custId'";
    $selectResult = mysqli_query($con, $selectQuery);
    $custData = mysqli_fetch_assoc($selectResult);

    echo json_encode([
        "status" => true,
        "message" => "Customer updated successfully",
        "data" => $custData
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

} // End of POST method check

?>
