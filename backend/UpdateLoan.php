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

            // Check if a new image was uploaded
            if (isset($_FILES['image']) && $_FILES['image']['error'] == 0) {
                $image = $uploadDir . basename($_FILES['image']['name']);
                if (!move_uploaded_file($_FILES['image']['tmp_name'], $uploadPath . basename($_FILES['image']['name']))) {
                    throw new Exception("Failed to upload image");
                }

                // Update with new image and recalculated fields
                $stmt = $con->prepare("UPDATE loan SET amount = ?, rate = ?, startdate = ?, endDate = ?, image = ?, note = ?, userId = ?, custId = ?, updatedAmount = ?, totalDeposite = ?, interest = ? WHERE loanid = ?");

                if ($stmt == false) {
                    throw new Exception("Prepare failed: " . $con->error);
                }

                $stmt->bind_param("ssssssssiddi", $amount, $rate, $startDate, $endDate, $image, $note, $userId, $custId, $newUpdatedAmount, $totalDeposits, $newMonthlyInterest, $loanId);
            } else {
                // Update without changing the image but with recalculated fields
                $stmt = $con->prepare("UPDATE loan SET amount = ?, rate = ?, startdate = ?, endDate = ?, note = ?, userId = ?, custId = ?, updatedAmount = ?, totalDeposite = ?, interest = ? WHERE loanid = ?");

                if ($stmt == false) {
                    throw new Exception("Prepare failed: " . $con->error);
                }

                $stmt->bind_param("sssssssiddi", $amount, $rate, $startDate, $endDate, $note, $userId, $custId, $newUpdatedAmount, $totalDeposits, $newMonthlyInterest, $loanId);
            }

            if ($stmt->execute()) {
                // Commit transaction
                $con->commit();
                http_response_code(200);
                echo json_encode([
                    "status" => "true",
                    "message" => "Record updated successfully",
                    "updatedAmount" => $newUpdatedAmount,
                    "totalDeposits" => $totalDeposits,
                    "newMonthlyInterest" => $newMonthlyInterest
                ]);
            } else {
                throw new Exception("Database update failed: " . $stmt->error);
            }

            $stmt->close();
            $depositStmt->close();

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