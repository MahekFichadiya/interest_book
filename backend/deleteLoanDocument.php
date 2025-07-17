<?php
include("Connection.php");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $documentId = $_POST['documentId'] ?? null;
    $userId = $_POST['userId'] ?? null;

    if (!$documentId || !$userId) {
        http_response_code(400);
        echo json_encode([
            "status" => "false", 
            "message" => "Missing required parameters: documentId and userId"
        ]);
        exit;
    }

    try {
        // Start transaction for data consistency
        mysqli_autocommit($con, FALSE);

        // First, verify that the document exists and belongs to a loan owned by the user
        $verifyQuery = "SELECT ld.documentId, ld.loanId, ld.documentPath, l.userId 
                       FROM loan_documents ld
                       INNER JOIN loan l ON ld.loanId = l.loanId
                       WHERE ld.documentId = ? AND l.userId = ?";
        
        $verifyStmt = mysqli_prepare($con, $verifyQuery);
        
        if (!$verifyStmt) {
            throw new Exception("Failed to prepare verification query: " . mysqli_error($con));
        }
        
        mysqli_stmt_bind_param($verifyStmt, "ii", $documentId, $userId);
        mysqli_stmt_execute($verifyStmt);
        $verifyResult = mysqli_stmt_get_result($verifyStmt);
        
        if (mysqli_num_rows($verifyResult) === 0) {
            http_response_code(404);
            echo json_encode([
                "status" => "false",
                "message" => "Document not found or access denied"
            ]);
            exit;
        }
        
        $documentInfo = mysqli_fetch_assoc($verifyResult);
        mysqli_stmt_close($verifyStmt);

        // Delete the document (trigger will automatically archive it)
        $deleteQuery = "DELETE FROM loan_documents WHERE documentId = ?";
        $deleteStmt = mysqli_prepare($con, $deleteQuery);
        
        if (!$deleteStmt) {
            throw new Exception("Failed to prepare delete query: " . mysqli_error($con));
        }
        
        mysqli_stmt_bind_param($deleteStmt, "i", $documentId);
        
        if (!mysqli_stmt_execute($deleteStmt)) {
            throw new Exception("Failed to delete document: " . mysqli_stmt_error($deleteStmt));
        }
        
        $deletedRows = mysqli_stmt_affected_rows($deleteStmt);
        mysqli_stmt_close($deleteStmt);

        if ($deletedRows === 0) {
            throw new Exception("No document was deleted");
        }

        // Verify the document was archived
        $archiveCheckQuery = "SELECT COUNT(*) as archived_count 
                             FROM history_loan_documents 
                             WHERE loanId = ? AND documentPath = ?";
        
        $archiveStmt = mysqli_prepare($con, $archiveCheckQuery);
        mysqli_stmt_bind_param($archiveStmt, "is", $documentInfo['loanId'], $documentInfo['documentPath']);
        mysqli_stmt_execute($archiveStmt);
        $archiveResult = mysqli_stmt_get_result($archiveStmt);
        $archiveData = mysqli_fetch_assoc($archiveResult);
        mysqli_stmt_close($archiveStmt);

        // Commit transaction
        mysqli_commit($con);

        http_response_code(200);
        echo json_encode([
            "status" => "true",
            "message" => "Document deleted and archived successfully",
            "deletedDocument" => [
                "documentId" => $documentInfo['documentId'],
                "loanId" => $documentInfo['loanId'],
                "documentPath" => $documentInfo['documentPath'],
                "fileName" => basename($documentInfo['documentPath'])
            ],
            "archived" => $archiveData['archived_count'] > 0,
            "archiveCount" => (int)$archiveData['archived_count']
        ]);

    } catch (Exception $e) {
        // Rollback transaction on error
        mysqli_rollback($con);
        http_response_code(500);
        echo json_encode([
            "status" => "false",
            "message" => "Error deleting document: " . $e->getMessage()
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
