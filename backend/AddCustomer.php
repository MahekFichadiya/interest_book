<?php

include("Connection.php");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Handle both JSON and form data
    if (isset($_POST['custName'])) {
        // Form data (with file upload)
        $custName = $_POST['custName'];
        $custPhn = $_POST['custPhn'];
        $custAddress = $_POST['custAddress'];
        $date = $_POST['date'];
        $userId = $_POST['userId'];

        // Debug log for form data
        error_log("AddCustomer.php - Form data received: custName=$custName, custPhn=$custPhn, userId=$userId");
    } else {
        // JSON data (without file upload)
        $json = file_get_contents("php://input");
        $data = json_decode($json);
        $custName = $data->custName;
        $custPhn = $data->custPhn;
        $custAddress = $data->custAddress;
        $date = $data->date;
        $userId = $data->userId;

        // Debug log for JSON data
        error_log("AddCustomer.php - JSON data received: custName=$custName, custPhn=$custPhn, userId=$userId");
    }

    // Convert userId to integer and validate required fields
    $userId = intval($userId);

    if (empty($custName) || empty($custPhn) || $userId <= 0) {
        http_response_code(400);
        $response = [
            "status" => false,
            "message" => "Missing required fields or invalid userId",
            "debug" => [
                "custName" => $custName,
                "custPhn" => $custPhn,
                "userId" => $userId,
                "userIdOriginal" => $_POST['userId'] ?? $data->userId ?? 'not set',
                "date" => $date
            ]
        ];
        echo json_encode($response);
        exit;
    }

    // Handle customer picture upload
    $uploadDir = "OmJavellerssHTML/CustomerImages/";
    $uploadPath = $_SERVER['DOCUMENT_ROOT'] . '/' . $uploadDir;

    if (!file_exists($uploadPath)) {
        if (!mkdir($uploadPath, 0777, true)) {
            http_response_code(500);
            echo json_encode(["status" => "false", "message" => "Failed to create directory: $uploadPath"]);
            exit;
        }
    }

    $custPic = null;
    if (isset($_FILES['custPic']) && $_FILES['custPic']['error'] == 0) {
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

// Check if customer with same phone number already exists for this user
$checkQuery = "SELECT custId, custName FROM customer WHERE custPhn = ? AND userId = ?";
$checkStmt = mysqli_prepare($con, $checkQuery);
mysqli_stmt_bind_param($checkStmt, "si", $custPhn, $userId);
mysqli_stmt_execute($checkStmt);
$checkResult = mysqli_stmt_get_result($checkStmt);

if (mysqli_num_rows($checkResult) > 0) {
    // Customer already exists
    $existingCustomer = mysqli_fetch_assoc($checkResult);

    http_response_code(409); // Conflict status code
    $response = [
        "status" => false,
        "message" => "Customer with this phone number already exists",
        "error" => "Duplicate customer",
        "existingCustomer" => [
            "custId" => $existingCustomer['custId'],
            "custName" => $existingCustomer['custName'],
            "custPhn" => $custPhn
        ]
    ];
    echo json_encode($response);
    mysqli_stmt_close($checkStmt);
    exit;
}

mysqli_stmt_close($checkStmt);

// Validate that userId exists in user table
$userCheckQuery = "SELECT userId FROM user WHERE userId = ?";
$userCheckStmt = mysqli_prepare($con, $userCheckQuery);
mysqli_stmt_bind_param($userCheckStmt, "i", $userId);
mysqli_stmt_execute($userCheckStmt);
$userCheckResult = mysqli_stmt_get_result($userCheckStmt);

if (mysqli_num_rows($userCheckResult) == 0) {
    mysqli_stmt_close($userCheckStmt);

    // Get available users for debugging
    $availableUsersQuery = "SELECT userId, name, email FROM user ORDER BY userId";
    $availableUsersResult = mysqli_query($con, $availableUsersQuery);
    $availableUsers = [];
    while ($row = mysqli_fetch_assoc($availableUsersResult)) {
        $availableUsers[] = $row;
    }

    http_response_code(400);
    $response = [
        "status" => false,
        "message" => "User session expired or invalid. Please logout and login again.",
        "error_code" => "INVALID_USER_ID",
        "debug" => [
            "requestedUserId" => $userId,
            "userIdType" => gettype($userId),
            "availableUsers" => $availableUsers
        ]
    ];
    echo json_encode($response);
    exit;
}
mysqli_stmt_close($userCheckStmt);

// Proceed with insertion using prepared statement for security
$insertQuery = "INSERT INTO customer (custName, custPhn, custAddress, custPic, date, userId) VALUES (?, ?, ?, ?, ?, ?)";
$insertStmt = mysqli_prepare($con, $insertQuery);
mysqli_stmt_bind_param($insertStmt, "sssssi", $custName, $custPhn, $custAddress, $custPic, $date, $userId);
$result = mysqli_stmt_execute($insertStmt);

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
            "custPic" => $custPic,
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

mysqli_stmt_close($insertStmt);

} // End of POST method check

?>