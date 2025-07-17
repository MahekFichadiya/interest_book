<?php
include("Connection.php");

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $userId = $_GET['userId'] ?? null;

    if (!$userId) {
        http_response_code(400);
        echo json_encode([
            "status" => "false", 
            "message" => "Missing required parameter: userId"
        ]);
        exit;
    }

    try {
        // Get all history loans for the user with document counts
        $historyQuery = "SELECT 
                            hl.loanId,
                            hl.amount,
                            hl.rate,
                            hl.startDate,
                            hl.endDate,
                            hl.note,
                            hl.updatedAmount,
                            hl.type,
                            hl.custId,
                            hl.custName,
                            hl.paymentMode,
                            COUNT(hld.documentId) as documentCount
                        FROM historyloan hl
                        LEFT JOIN history_loan_documents hld ON hl.loanId = hld.loanId
                        WHERE hl.userId = ?
                        GROUP BY hl.loanId, hl.amount, hl.rate, hl.startDate, hl.endDate, 
                                hl.note, hl.updatedAmount, hl.type, hl.custId, hl.custName, hl.paymentMode
                        ORDER BY hl.endDate DESC, hl.startDate DESC";
        
        $historyStmt = mysqli_prepare($con, $historyQuery);
        
        if (!$historyStmt) {
            throw new Exception("Failed to prepare history query: " . mysqli_error($con));
        }
        
        mysqli_stmt_bind_param($historyStmt, "i", $userId);
        mysqli_stmt_execute($historyStmt);
        $historyResult = mysqli_stmt_get_result($historyStmt);
        
        $historyLoans = [];
        $totalAmount = 0;
        $youGaveTotal = 0;
        $youGotTotal = 0;
        
        while ($row = mysqli_fetch_assoc($historyResult)) {
            $loanData = [
                "loanId" => $row['loanId'],
                "amount" => $row['amount'],
                "rate" => $row['rate'],
                "startDate" => $row['startDate'],
                "endDate" => $row['endDate'],
                "note" => $row['note'],
                "updatedAmount" => $row['updatedAmount'],
                "type" => $row['type'],
                "custId" => $row['custId'],
                "custName" => $row['custName'] ?? 'Unknown Customer',
                "paymentMode" => $row['paymentMode'] ?? 'cash',
                "documentCount" => (int)$row['documentCount'],
                "hasDocuments" => (int)$row['documentCount'] > 0
            ];
            
            $historyLoans[] = $loanData;
            $totalAmount += (int)$row['amount'];
            
            // Calculate totals by type
            if ($row['type'] == 0) {
                $youGotTotal += (int)$row['amount'];
            } else {
                $youGaveTotal += (int)$row['amount'];
            }
        }
        
        mysqli_stmt_close($historyStmt);

        // Get summary statistics
        $summaryQuery = "SELECT 
                            COUNT(*) as totalHistoryLoans,
                            SUM(CASE WHEN type = 0 THEN amount ELSE 0 END) as youGotTotal,
                            SUM(CASE WHEN type = 1 THEN amount ELSE 0 END) as youGaveTotal,
                            SUM(amount) as grandTotal
                        FROM historyloan 
                        WHERE userId = ?";
        
        $summaryStmt = mysqli_prepare($con, $summaryQuery);
        mysqli_stmt_bind_param($summaryStmt, "i", $userId);
        mysqli_stmt_execute($summaryStmt);
        $summaryResult = mysqli_stmt_get_result($summaryStmt);
        $summary = mysqli_fetch_assoc($summaryResult);
        mysqli_stmt_close($summaryStmt);

        // Get document statistics
        $docStatsQuery = "SELECT 
                            COUNT(DISTINCT hld.loanId) as loansWithDocuments,
                            COUNT(hld.documentId) as totalDocuments
                        FROM history_loan_documents hld
                        INNER JOIN historyloan hl ON hld.loanId = hl.loanId
                        WHERE hl.userId = ?";
        
        $docStatsStmt = mysqli_prepare($con, $docStatsQuery);
        mysqli_stmt_bind_param($docStatsStmt, "i", $userId);
        mysqli_stmt_execute($docStatsStmt);
        $docStatsResult = mysqli_stmt_get_result($docStatsStmt);
        $docStats = mysqli_fetch_assoc($docStatsResult);
        mysqli_stmt_close($docStatsStmt);

        http_response_code(200);
        echo json_encode([
            "status" => "true",
            "message" => "History loans retrieved successfully",
            "historyLoans" => $historyLoans,
            "summary" => [
                "totalLoans" => (int)$summary['totalHistoryLoans'],
                "youGotTotal" => (int)$summary['youGotTotal'],
                "youGaveTotal" => (int)$summary['youGaveTotal'],
                "grandTotal" => (int)$summary['grandTotal'],
                "loansWithDocuments" => (int)$docStats['loansWithDocuments'],
                "totalDocuments" => (int)$docStats['totalDocuments']
            ]
        ]);

    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode([
            "status" => "false",
            "message" => "Error retrieving history loans: " . $e->getMessage()
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
