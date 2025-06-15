<?php
include("Connection.php");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $amount = isset($_POST['amount']) ? $_POST['amount'] : null;
    $rate = isset($_POST['rate']) ? $_POST['rate'] : null;
    $startDate = isset($_POST['startDate']) ? $_POST['startDate'] : null;
    $endDate = isset($_POST['endDate']) ? $_POST['endDate'] : null;
    $note = isset($_POST['note']) ? $_POST['note'] : null;
    $type = isset($_POST['type']) ? $_POST['type'] : null;
    $updatedAmount = $amount;
    $userId = isset($_POST['userId']) ? $_POST['userId'] : null;
    $custId = isset($_POST['custId']) ? $_POST['custId'] : null;

    $uploadDir = "OmJavellerssHTML/LoanImages/";
    $uploadPath = $_SERVER['DOCUMENT_ROOT'] . '/' . $uploadDir;

    if (!file_exists($uploadPath)) {
        if (!mkdir($uploadPath, 0777, true)) {
            http_response_code(500);
            echo json_encode(["status" => "false", "message" => "Failed to create directory: $uploadPath"]);
            exit;
        }
    }

    $image = null;
    if (isset($_FILES['image']) && $_FILES['image']['error'] == 0) {
        $image = $uploadDir . basename($_FILES['image']['name']);
        if (!move_uploaded_file($_FILES['image']['tmp_name'], $uploadPath . basename($_FILES['image']['name']))) {
            $image = null;
        }
    }

    // Validate required fields
    if ($amount && $rate && $startDate && $userId && $custId && $note && $type !== null) {

        // ✅ Prepare the SQL statement first
        $stmt = $con->prepare("INSERT INTO loan (amount, rate, startDate, endDate, image, note, updatedAmount, type, userId, custId)
                               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

        if ($stmt === false) {
            http_response_code(500);
            echo json_encode(["status" => "false", "message" => "Prepare failed: " . htmlspecialchars($con->error)]);
            exit;
        }

        //✅ Now bind parameters using the correct variable names
        $stmt->bind_param("ddssssiiii", $amount, $rate, $startDate, $endDate, $image, $note, $updatedAmount, $type, $userId, $custId);

        if ($stmt->execute()) {
            http_response_code(200);
            echo json_encode(["status" => "true", "message" => "Record inserted successfully"]);
        } else {
            http_response_code(400);
            echo json_encode(["status" => "false", "message" => "Database insertion failed: " . $stmt->error]);
        }

        $stmt->close();
    }
} else {
    http_response_code(405);
    echo json_encode(["status" => "false", "message" => "Invalid request method"]);
}

$con->close();
?>