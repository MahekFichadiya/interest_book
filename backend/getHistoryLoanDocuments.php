<?php
include("Connection.php");

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $loanId = $_GET['loanId'] ?? null;
    $userId = $_GET['userId'] ?? null;

    if (!$loanId || !$userId) {
        http_response_code(400);
        echo json_encode([
            "status" => "false", 
            "message" => "Missing required parameters: loanId and userId"
        ]);
        exit;
    }

    try {
        // First check what columns exist in historyloan table
        $columnsResult = mysqli_query($con, "DESCRIBE historyloan");
        $availableColumns = [];
        while ($row = mysqli_fetch_assoc($columnsResult)) {
            $availableColumns[] = $row['Field'];
        }

        // Verify that the loan exists in historyloan and belongs to the user
        $verifyQuery = "SELECT loanId, amount, note, startDate, endDate, custId, image FROM historyloan WHERE loanId = ? AND userId = ?";
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
                "message" => "History loan not found or access denied"
            ]);
            exit;
        }

        $loanInfo = mysqli_fetch_assoc($verifyResult);

        // Get customer name from customer table
        $custQuery = "SELECT custName FROM customer WHERE custId = ?";
        $custStmt = mysqli_prepare($con, $custQuery);
        if ($custStmt) {
            mysqli_stmt_bind_param($custStmt, "i", $loanInfo['custId']);
            mysqli_stmt_execute($custStmt);
            $custResult = mysqli_stmt_get_result($custStmt);
            if ($custRow = mysqli_fetch_assoc($custResult)) {
                $loanInfo['custName'] = $custRow['custName'];
            } else {
                $loanInfo['custName'] = 'Unknown Customer';
            }
            mysqli_stmt_close($custStmt);
        } else {
            $loanInfo['custName'] = 'Unknown Customer';
        }

        mysqli_stmt_close($verifyStmt);

        // Get all documents for this history loan
        $documentsQuery = "SELECT id as documentId, documentPath, fileName, archivedDate
                          FROM history_loan_documents
                          WHERE loanId = ?
                          ORDER BY archivedDate DESC";
        $documentsStmt = mysqli_prepare($con, $documentsQuery);
        
        if (!$documentsStmt) {
            throw new Exception("Failed to prepare documents query: " . mysqli_error($con));
        }
        
        mysqli_stmt_bind_param($documentsStmt, "i", $loanId);
        mysqli_stmt_execute($documentsStmt);
        $documentsResult = mysqli_stmt_get_result($documentsStmt);
        
        $documents = [];
        while ($row = mysqli_fetch_assoc($documentsResult)) {
            $documents[] = [
                "documentId" => $row['documentId'],
                "loanId" => $loanId,
                "documentPath" => $row['documentPath'],
                "archivedDate" => $row['archivedDate'],
                "fileName" => $row['fileName'] ?: basename($row['documentPath'])
            ];
        }
        
        mysqli_stmt_close($documentsStmt);

        // Return loan info with documents
        http_response_code(200);
        echo json_encode([
            "status" => "true",
            "message" => "History loan documents retrieved successfully",
            "loanInfo" => [
                "loanId" => $loanInfo['loanId'],
                "amount" => $loanInfo['amount'],
                "custName" => $loanInfo['custName'],
                "note" => $loanInfo['note'],
                "startDate" => $loanInfo['startDate'],
                "endDate" => $loanInfo['endDate'],
                "image" => $loanInfo['image']
            ],
            "loanImage" => !empty($loanInfo['image']) && $loanInfo['image'] !== '' ? [
                "documentId" => "loan_image",
                "loanId" => $loanId,
                "documentPath" => $loanInfo['image'],
                "archivedDate" => null,
                "fileName" => basename($loanInfo['image']),
                "isLoanImage" => true
            ] : null,
            "documents" => $documents,
            "documentCount" => count($documents),
            "totalDocuments" => count($documents) + (!empty($loanInfo['image']) && $loanInfo['image'] !== '' ? 1 : 0)
        ]);

    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode([
            "status" => "false",
            "message" => "Error retrieving history loan documents: " . $e->getMessage()
        ]);
    }

} else {
    http_response_code(405);
    echo json_encode([
        "status" => "false", 
        "message" => "Invalid request method"
    ]);
}

$con->close();
?>
