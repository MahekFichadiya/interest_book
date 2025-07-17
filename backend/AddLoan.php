<?php
include("Connection.php");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $amount = isset($_POST['amount']) ? $_POST['amount'] : null;
    $rate = isset($_POST['rate']) ? $_POST['rate'] : null;
    $startDate = isset($_POST['startDate']) ? $_POST['startDate'] : null;
    $endDate = isset($_POST['endDate']) ? $_POST['endDate'] : null;
    $note = isset($_POST['note']) ? $_POST['note'] : null;
    $type = isset($_POST['type']) ? $_POST['type'] : null;
    $paymentMode = isset($_POST['paymentMode']) ? $_POST['paymentMode'] : 'cash';
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

    // Handle multiple documents upload
    $uploadedDocuments = [];
    if (isset($_FILES['documents'])) {
        $fileCount = count($_FILES['documents']['name']);

        for ($i = 0; $i < $fileCount; $i++) {
            if ($_FILES['documents']['error'][$i] == 0) {
                $fileName = basename($_FILES['documents']['name'][$i]);
                $targetFilePath = $uploadPath . $fileName;
                $documentPath = $uploadDir . $fileName;

                // Check if document already exists in the folder
                if (file_exists($targetFilePath)) {
                    // Document already exists, just use the existing path
                    $uploadedDocuments[] = $documentPath;
                } else {
                    // Document doesn't exist, save the new document
                    if (move_uploaded_file($_FILES['documents']['tmp_name'][$i], $targetFilePath)) {
                        $uploadedDocuments[] = $documentPath;
                    }
                }
            }
        }
    }

    // Validate required fields
    if ($amount && $rate && $startDate && $userId && $custId && $note && $type !== null) {

        // ✅ Prepare the SQL statement first (trigger will calculate interest fields)
        $stmt = $con->prepare("INSERT INTO loan (amount, rate, startDate, endDate, note, updatedAmount, type, userId, custId, paymentMode, interest, dailyInterest, totalDailyInterest, totalDeposite)
                               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 0, 0, 0)");

        if ($stmt === false) {
            http_response_code(500);
            echo json_encode(["status" => "false", "message" => "Prepare failed: " . htmlspecialchars($con->error)]);
            exit;
        }

        // ✅ First, check if the customer exists
        $checkCustomerQuery = "SELECT custId FROM customer WHERE custId = ?";
        $checkStmt = mysqli_prepare($con, $checkCustomerQuery);
        if (!$checkStmt) {
            http_response_code(500);
            echo json_encode(["status" => "false", "message" => "Failed to prepare customer check query: " . mysqli_error($con)]);
            exit;
        }

        mysqli_stmt_bind_param($checkStmt, "i", $custId);
        if (!mysqli_stmt_execute($checkStmt)) {
            http_response_code(500);
            echo json_encode(["status" => "false", "message" => "Failed to check customer existence: " . mysqli_stmt_error($checkStmt)]);
            exit;
        }

        $checkResult = mysqli_stmt_get_result($checkStmt);
        if (mysqli_num_rows($checkResult) === 0) {
            http_response_code(400);
            echo json_encode([
                "status" => "false",
                "message" => "Customer not found. The customer may have been deleted.",
                "error_code" => "CUSTOMER_NOT_FOUND"
            ]);
            mysqli_stmt_close($checkStmt);
            exit;
        }
        mysqli_stmt_close($checkStmt);

        //✅ Now bind parameters using the correct variable names
        $stmt->bind_param("ddsssiiiis", $amount, $rate, $startDate, $endDate, $note, $updatedAmount, $type, $userId, $custId, $paymentMode);

        if ($stmt->execute()) {
            $loanId = mysqli_insert_id($con);

            // Insert documents into loan_documents table
            if (!empty($uploadedDocuments)) {
                $docStmt = $con->prepare("INSERT INTO loan_documents (loanId, documentPath) VALUES (?, ?)");
                foreach ($uploadedDocuments as $documentPath) {
                    $docStmt->bind_param("is", $loanId, $documentPath);
                    $docStmt->execute();
                }
                $docStmt->close();
            }

            http_response_code(200);
            echo json_encode([
                "status" => "true",
                "message" => "Record inserted successfully",
                "loanId" => $loanId,
                "documentsUploaded" => count($uploadedDocuments)
            ]);
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