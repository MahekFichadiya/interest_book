<?php
include("Connection.php");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $loanId = $_POST['loanId'] ?? null;
    $amount = $_POST['amount'] ?? null;
    $rate = $_POST['rate'] ?? null;
    $startDate = $_POST['startDate'] ?? null;
    $endDate = $_POST['endDate'] ?? null;
    $note = $_POST['note'] ?? null;
    $userId = $_POST['userId'] ?? null;
    $custId = $_POST['custId'] ?? null;

    $uploadDir = "OmjavellersHtml/LoanImages/";
    $uploadPath = $_SERVER['DOCUMENT_ROOT'] . '/' . $uploadDir;

    if (!file_exists($uploadPath)) {
        if (!mkdir($uploadPath, 0777, true)) {
            http_response_code(500);
            echo json_encode(["status" => "false", "message" => "Failed to create directory: $uploadPath"]);
            exit;
        }
    }

    if ($loanId && $amount && $rate && $startDate && $userId && $custId && $note) {
        // endDate is optional, so we don't validate it here

        // Start transaction for data consistency
        $con->autocommit(FALSE);

        try {
            // First, calculate total deposits for this loan
            $depositQuery = "SELECT COALESCE(SUM(depositeAmount), 0) as totalDeposits FROM deposite WHERE loanid = ?";
            $depositStmt = $con->prepare($depositQuery);
            if (!$depositStmt) {
                throw new Exception("Failed to prepare deposit query: " . $con->error);
            }
            $depositStmt->bind_param("i", $loanId);
            $depositStmt->execute();
            $depositResult = $depositStmt->get_result();
            $depositRow = $depositResult->fetch_assoc();
            $totalDeposits = $depositRow['totalDeposits'];

            // Calculate new updatedAmount (new principal - existing deposits)
            $newUpdatedAmount = max(0, $amount - $totalDeposits);

            // Calculate new monthly interest based on updated amount
            $newMonthlyInterest = round(($newUpdatedAmount * $rate) / 100, 2);

            // Recalculate totalInterest from scratch based on months elapsed since start date
            $startDateTime = new DateTime($startDate);
            $currentDateTime = new DateTime();

            // Calculate months elapsed more accurately
            $yearDiff = (int)$currentDateTime->format('Y') - (int)$startDateTime->format('Y');
            $monthDiff = (int)$currentDateTime->format('m') - (int)$startDateTime->format('m');
            $dayDiff = (int)$currentDateTime->format('d') - (int)$startDateTime->format('d');

            // Calculate total months
            $monthsElapsed = ($yearDiff * 12) + $monthDiff;

            // If we haven't reached the same day of the month yet, subtract 1 month
            if ($dayDiff < 0) {
                $monthsElapsed--;
            }

            // Ensure months elapsed is not negative
            $monthsElapsed = max(0, $monthsElapsed);

            // Calculate total interest that should have accumulated
            $newTotalInterest = round($newMonthlyInterest * $monthsElapsed, 2);

            // Debug logging (remove in production)
            error_log("UpdateLoan Debug - Start Date: $startDate");
            error_log("UpdateLoan Debug - Current Date: " . $currentDateTime->format('Y-m-d H:i:s'));
            error_log("UpdateLoan Debug - Months Elapsed: $monthsElapsed");
            error_log("UpdateLoan Debug - Monthly Interest: $newMonthlyInterest");
            error_log("UpdateLoan Debug - Calculated Total Interest: $newTotalInterest");

            // Get total interest payments made to subtract from accumulated interest
            $interestPaymentsQuery = "SELECT COALESCE(SUM(interestAmount), 0) as totalInterestPaid FROM interest WHERE loanId = ?";
            $interestStmt = $con->prepare($interestPaymentsQuery);
            if (!$interestStmt) {
                throw new Exception("Failed to prepare interest payments query: " . $con->error);
            }
            $interestStmt->bind_param("i", $loanId);
            $interestStmt->execute();
            $interestResult = $interestStmt->get_result();
            $interestRow = $interestResult->fetch_assoc();
            $totalInterestPaid = $interestRow['totalInterestPaid'];

            // Final totalInterest = accumulated interest - payments made
            $finalTotalInterest = max(0, $newTotalInterest - $totalInterestPaid);

            // Calculate daily interest and total daily interest
            $newDailyInterest = round($newMonthlyInterest / 30, 2);

            // Calculate days passed since loan start
            $daysPassed = max(0, $currentDateTime->diff($startDateTime)->days);

            // Calculate total daily interest (only for days beyond monthly periods)
            // Daily interest starts from the day AFTER the monthly period ends
            if ($daysPassed <= 30) {
                $newTotalDailyInterest = 0; // No daily interest accumulation until after 30 days
            } else {
                $completeMonths = floor($daysPassed / 30);
                $daysBeyondMonthly = $daysPassed - ($completeMonths * 30);
                $newTotalDailyInterest = round($newDailyInterest * $daysBeyondMonthly, 2);
            }

            // Handle multiple documents upload if provided
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

            // Update loan without image field but with recalculated fields including totalInterest, dailyInterest, and totalDailyInterest
            $stmt = $con->prepare("UPDATE loan SET amount = ?, rate = ?, startdate = ?, endDate = ?, note = ?, userId = ?, custId = ?, updatedAmount = ?, totalDeposite = ?, interest = ?, totalInterest = ?, dailyInterest = ?, totalDailyInterest = ?, lastInterestUpdatedAt = CURDATE() WHERE loanid = ?");

            if ($stmt == false) {
                throw new Exception("Prepare failed: " . $con->error);
            }

            $stmt->bind_param("sssssssiddddi", $amount, $rate, $startDate, $endDate, $note, $userId, $custId, $newUpdatedAmount, $totalDeposits, $newMonthlyInterest, $finalTotalInterest, $newDailyInterest, $newTotalDailyInterest, $loanId);

            if ($stmt->execute()) {
                // Insert new documents into loan_documents table if any were uploaded
                if (!empty($uploadedDocuments)) {
                    $docStmt = $con->prepare("INSERT INTO loan_documents (loanId, documentPath) VALUES (?, ?)");
                    foreach ($uploadedDocuments as $documentPath) {
                        $docStmt->bind_param("is", $loanId, $documentPath);
                        $docStmt->execute();
                    }
                    $docStmt->close();
                }

                // Commit transaction
                $con->commit();
                http_response_code(200);
                echo json_encode([
                    "status" => "true",
                    "message" => "Record updated successfully",
                    "updatedAmount" => $newUpdatedAmount,
                    "totalDeposits" => $totalDeposits,
                    "newMonthlyInterest" => $newMonthlyInterest,
                    "newTotalInterest" => $finalTotalInterest,
                    "newDailyInterest" => $newDailyInterest,
                    "newTotalDailyInterest" => $newTotalDailyInterest,
                    "monthsElapsed" => $monthsElapsed,
                    "daysPassed" => $daysPassed,
                    "totalInterestPaid" => $totalInterestPaid,
                    "documentsAdded" => count($uploadedDocuments)
                ]);
            } else {
                throw new Exception("Database update failed: " . $stmt->error);
            }

            $stmt->close();
            $depositStmt->close();
            $interestStmt->close();

        } catch (Exception $e) {
            // Rollback transaction on error
            $con->rollback();
            http_response_code(400);
            echo json_encode(["status" => "false", "message" => $e->getMessage()]);
        } finally {
            // Restore autocommit
            $con->autocommit(TRUE);
        }
    } else {
        http_response_code(400);
        echo json_encode(["status" => "false", "message" => "Missing required form fields"]);
    }
} else {
    http_response_code(405);
    echo json_encode(["status" => "false", "message" => "Invalid request method"]);
}

$con->close();
?>