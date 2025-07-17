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
        // First verify that the loan exists and belongs to the user
        $verifyQuery = "SELECT loanId, amount, note, startDate, endDate 
                       FROM loan 
                       WHERE loanId = ? AND userId = ?";
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
        
        $loanInfo = mysqli_fetch_assoc($verifyResult);
        mysqli_stmt_close($verifyStmt);

        // Get all documents for this loan
        $documentsQuery = "SELECT documentId, documentPath 
                          FROM loan_documents 
                          WHERE loanId = ? 
                          ORDER BY documentId ASC";
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
                "fileName" => basename($row['documentPath'])
            ];
        }
        
        mysqli_stmt_close($documentsStmt);

        // Return loan info with documents
        http_response_code(200);
        echo json_encode([
            "status" => "true",
            "message" => "Loan documents retrieved successfully",
            "loanInfo" => [
                "loanId" => $loanInfo['loanId'],
                "amount" => $loanInfo['amount'],
                "note" => $loanInfo['note'],
                "startDate" => $loanInfo['startDate'],
                "endDate" => $loanInfo['endDate']
            ],
            "documents" => $documents,
            "documentCount" => count($documents)
        ]);

    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode([
            "status" => "false",
            "message" => "Error retrieving loan documents: " . $e->getMessage()
        ]);
    }

} else {
    http_response_code(405);
    echo json_encode([
        "status" => "false",
        "message" => "Invalid request method. Use GET."
    ]);
}

mysqli_close($con);
?>
