<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

include 'Connection.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    // Validate required fields
    if (!isset($input['custId']) || !isset($input['userId']) || !isset($input['reminderTitle']) || !isset($input['reminderDate'])) {
        echo json_encode([
            'success' => false,
            'message' => 'Missing required fields: custId, userId, reminderTitle, reminderDate'
        ]);
        exit;
    }
    
    $custId = $input['custId'];
    $loanId = isset($input['loanId']) ? $input['loanId'] : null;
    $userId = $input['userId'];
    $reminderType = isset($input['reminderType']) ? $input['reminderType'] : 'interest';
    $reminderTitle = $input['reminderTitle'];
    $reminderMessage = isset($input['reminderMessage']) ? $input['reminderMessage'] : null;
    $reminderDate = $input['reminderDate'];
    $reminderTime = isset($input['reminderTime']) ? $input['reminderTime'] : '10:00:00';
    $isRecurring = isset($input['isRecurring']) ? $input['isRecurring'] : 0;
    $recurringInterval = isset($input['recurringInterval']) ? $input['recurringInterval'] : null;
    
    try {
        // Validate customer exists
        $customerCheck = "SELECT custId FROM customer WHERE custId = ? AND userId = ?";
        $stmt = mysqli_prepare($con, $customerCheck);
        mysqli_stmt_bind_param($stmt, "ii", $custId, $userId);
        mysqli_stmt_execute($stmt);
        $result = mysqli_stmt_get_result($stmt);
        
        if (mysqli_num_rows($result) == 0) {
            echo json_encode([
                'success' => false,
                'message' => 'Customer not found or access denied'
            ]);
            exit;
        }
        
        // Validate loan exists if loanId is provided
        if ($loanId) {
            $loanCheck = "SELECT loanId FROM loan WHERE loanId = ? AND custId = ? AND userId = ?";
            $stmt = mysqli_prepare($con, $loanCheck);
            mysqli_stmt_bind_param($stmt, "iii", $loanId, $custId, $userId);
            mysqli_stmt_execute($stmt);
            $result = mysqli_stmt_get_result($stmt);
            
            if (mysqli_num_rows($result) == 0) {
                echo json_encode([
                    'success' => false,
                    'message' => 'Loan not found or access denied'
                ]);
                exit;
            }
        }
        
        // Insert reminder
        $insertQuery = "INSERT INTO reminders (custId, loanId, userId, reminderType, reminderTitle, reminderMessage, reminderDate, reminderTime, isRecurring, recurringInterval) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        $stmt = mysqli_prepare($con, $insertQuery);
        mysqli_stmt_bind_param($stmt, "iiissssiis", $custId, $loanId, $userId, $reminderType, $reminderTitle, $reminderMessage, $reminderDate, $reminderTime, $isRecurring, $recurringInterval);
        
        if (mysqli_stmt_execute($stmt)) {
            $reminderId = mysqli_insert_id($con);
            
            // Create notification for the reminder
            $notificationTitle = "Reminder Set: " . $reminderTitle;
            $notificationMessage = "Reminder has been set for " . $reminderDate . " at " . $reminderTime;
            
            $notificationQuery = "INSERT INTO notifications (userId, custId, loanId, reminderId, notificationType, title, message, priority) VALUES (?, ?, ?, ?, 'reminder', ?, ?, 'medium')";
            $stmt2 = mysqli_prepare($con, $notificationQuery);
            mysqli_stmt_bind_param($stmt2, "iiiiss", $userId, $custId, $loanId, $reminderId, $notificationTitle, $notificationMessage);
            mysqli_stmt_execute($stmt2);
            
            echo json_encode([
                'success' => true,
                'message' => 'Reminder created successfully',
                'reminderId' => $reminderId
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to create reminder: ' . mysqli_error($con)
            ]);
        }
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Error: ' . $e->getMessage()
        ]);
    }
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Only POST method allowed'
    ]);
}

mysqli_close($con);
?>
