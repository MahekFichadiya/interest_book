<?php
include("Connection.php");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $loanId = $_POST['loanId'] ?? null;
    $userId = $_POST['userId'] ?? null;

    if (!$loanId || !$userId) {
        http_response_code(400);
        echo json_encode([
            "status" => "false", 
            "message" => "Missing required parameters: loanId and userId"
        ]);
        exit;
    }

    try {
        // First verify that the loan exists and belongs to the user
        $verifyQuery = "SELECT loanId FROM loan WHERE loanId = ? AND userId = ?";
        $verifyStmt = mysqli_prepare($con, $verifyQuery);
        
        if (!$verifyStmt) {
            throw new Exception("Failed to prepare verification query: " . mysqli_error($con));
        }
        
        mysqli_stmt_bind_param($verifyStmt, "ii", $loanId, $userId);
        mysqli_stmt_execute($verifyStmt);
        $verifyResult = mysqli_stmt_get_result($verifyStmt);
        
        if (mysqli_num_rows($verifyResult) === 0) {
            http_response_code(404);
            echo json_encode([
                "status" => "false",
                "message" => "Loan not found or access denied"
            ]);
            exit;
        }
        mysqli_stmt_close($verifyStmt);

        // Handle document upload
        if (!isset($_FILES['document']) || $_FILES['document']['error'] != 0) {
            http_response_code(400);
            echo json_encode([
                "status" => "false",
                "message" => "No document uploaded or upload error"
            ]);
            exit;
        }

        $uploadDir = "OmJavellerssHTML/LoanImages/";
        $uploadPath = $_SERVER['DOCUMENT_ROOT'] . '/' . $uploadDir;

        if (!file_exists($uploadPath)) {
            if (!mkdir($uploadPath, 0777, true)) {
                throw new Exception("Failed to create directory: $uploadPath");
            }
        }

        $fileName = basename($_FILES['document']['name']);
        $targetFilePath = $uploadPath . $fileName;
        $documentPath = $uploadDir . $fileName;

        // Check if document already exists
        if (file_exists($targetFilePath)) {
            // File already exists, check if it's already in database for this loan
            $checkExistingQuery = "SELECT documentId FROM loan_documents WHERE loanId = ? AND documentPath = ?";
            $checkStmt = mysqli_prepare($con, $checkExistingQuery);
            mysqli_stmt_bind_param($checkStmt, "is", $loanId, $documentPath);
            mysqli_stmt_execute($checkStmt);
            $checkResult = mysqli_stmt_get_result($checkStmt);
            
            if (mysqli_num_rows($checkResult) > 0) {
                http_response_code(409);
                echo json_encode([
                    "status" => "false",
                    "message" => "Document already exists for this loan"
                ]);
                exit;
            }
            mysqli_stmt_close($checkStmt);
        } else {
            // Upload new file
            if (!move_uploaded_file($_FILES['document']['tmp_name'], $targetFilePath)) {
                throw new Exception("Failed to upload document");
            }
        }

        // Add document to database
        $insertQuery = "INSERT INTO loan_documents (loanId, documentPath) VALUES (?, ?)";
        $insertStmt = mysqli_prepare($con, $insertQuery);
        
        if (!$insertStmt) {
            throw new Exception("Failed to prepare insert query: " . mysqli_error($con));
        }
        
        mysqli_stmt_bind_param($insertStmt, "is", $loanId, $documentPath);
        
        if (!mysqli_stmt_execute($insertStmt)) {
            throw new Exception("Failed to insert document: " . mysqli_stmt_error($insertStmt));
        }
        
        $documentId = mysqli_insert_id($con);
        mysqli_stmt_close($insertStmt);

        http_response_code(200);
        echo json_encode([
            "status" => "true",
            "message" => "Document added successfully",
            "document" => [
                "documentId" => $documentId,
                "loanId" => $loanId,
                "documentPath" => $documentPath,
                "fileName" => $fileName
            ]
        ]);

    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode([
            "status" => "false",
            "message" => "Error adding document: " . $e->getMessage()
        ]);
    }

} else {
    http_response_code(405);
    echo json_encode([
        "status" => "false",
        "message" => "Invalid request method. Use POST."
    ]);
}

mysqli_close($con);
?>
