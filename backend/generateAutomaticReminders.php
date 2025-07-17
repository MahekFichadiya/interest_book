<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

include 'Connection.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    $userId = isset($input['userId']) ? $input['userId'] : null;
    $daysAhead = isset($input['daysAhead']) ? $input['daysAhead'] : 2; // Default 2 days ahead
    
    if (!$userId) {
        echo json_encode([
            'success' => false,
            'message' => 'userId is required'
        ]);
        exit;
    }
    
    try {
        $remindersCreated = 0;
        $notificationsCreated = 0;
        
        // Get loans that have interest due in specified days
        $loansQuery = "SELECT l.*, c.custName, c.custPhn 
                       FROM loan l 
                       INNER JOIN customer c ON l.custId = c.custId 
                       WHERE l.userId = ? 
                       AND DATE_ADD(l.startDate, INTERVAL 30 DAY) = DATE_ADD(CURDATE(), INTERVAL ? DAY)";
        
        $stmt = mysqli_prepare($con, $loansQuery);
        mysqli_stmt_bind_param($stmt, "ii", $userId, $daysAhead);
        mysqli_stmt_execute($stmt);
        $result = mysqli_stmt_get_result($stmt);
        
        while ($loan = mysqli_fetch_assoc($result)) {
            $custId = $loan['custId'];
            $loanId = $loan['loanId'];
            $custName = $loan['custName'];
            $totalInterest = $loan['totalInterest'];
            $reminderDate = date('Y-m-d', strtotime("+{$daysAhead} days"));
            
            // Check if reminder already exists for this loan and date
            $existingReminderQuery = "SELECT reminderId FROM reminders 
                                     WHERE custId = ? AND loanId = ? AND userId = ? 
                                     AND reminderDate = ? AND reminderType = 'interest'";
            $stmt2 = mysqli_prepare($con, $existingReminderQuery);
            mysqli_stmt_bind_param($stmt2, "iiis", $custId, $loanId, $userId, $reminderDate);
            mysqli_stmt_execute($stmt2);
            $existingResult = mysqli_stmt_get_result($stmt2);
            
            if (mysqli_num_rows($existingResult) == 0) {
                // Create reminder
                $reminderTitle = "Interest Payment Due - {$custName}";
                $reminderMessage = "Interest payment of ₹{$totalInterest} is due for {$custName}. Please call to collect payment.";
                
                $insertReminderQuery = "INSERT INTO reminders (custId, loanId, userId, reminderType, reminderTitle, reminderMessage, reminderDate, reminderTime, isActive) 
                                       VALUES (?, ?, ?, 'interest', ?, ?, ?, '10:00:00', 1)";
                $stmt3 = mysqli_prepare($con, $insertReminderQuery);
                mysqli_stmt_bind_param($stmt3, "iiisss", $custId, $loanId, $userId, $reminderTitle, $reminderMessage, $reminderDate);
                
                if (mysqli_stmt_execute($stmt3)) {
                    $reminderId = mysqli_insert_id($con);
                    $remindersCreated++;
                    
                    // Create notification
                    $notificationTitle = "Payment Reminder Set";
                    $notificationMessage = "Automatic reminder created for {$custName}'s interest payment due on {$reminderDate}";
                    
                    $insertNotificationQuery = "INSERT INTO notifications (userId, custId, loanId, reminderId, notificationType, title, message, isActionRequired, actionType, priority) 
                                               VALUES (?, ?, ?, ?, 'payment_due', ?, ?, 1, 'call_customer', 'high')";
                    $stmt4 = mysqli_prepare($con, $insertNotificationQuery);
                    mysqli_stmt_bind_param($stmt4, "iiiiss", $userId, $custId, $loanId, $reminderId, $notificationTitle, $notificationMessage);
                    
                    if (mysqli_stmt_execute($stmt4)) {
                        $notificationsCreated++;
                    }
                }
            }
        }
        
        // Also check for custom recurring reminders that need to be created
        $recurringQuery = "SELECT * FROM reminders 
                          WHERE userId = ? AND isRecurring = 1 AND isActive = 1 
                          AND reminderDate < CURDATE()";
        $stmt5 = mysqli_prepare($con, $recurringQuery);
        mysqli_stmt_bind_param($stmt5, "i", $userId);
        mysqli_stmt_execute($stmt5);
        $recurringResult = mysqli_stmt_get_result($stmt5);
        
        while ($recurring = mysqli_fetch_assoc($recurringResult)) {
            $nextDate = null;
            $currentDate = $recurring['reminderDate'];
            
            switch ($recurring['recurringInterval']) {
                case 'daily':
                    $nextDate = date('Y-m-d', strtotime($currentDate . ' +1 day'));
                    break;
                case 'weekly':
                    $nextDate = date('Y-m-d', strtotime($currentDate . ' +1 week'));
                    break;
                case 'monthly':
                    $nextDate = date('Y-m-d', strtotime($currentDate . ' +1 month'));
                    break;
            }
            
            if ($nextDate && $nextDate <= date('Y-m-d', strtotime("+{$daysAhead} days"))) {
                // Update the existing reminder with new date
                $updateRecurringQuery = "UPDATE reminders SET reminderDate = ?, isCompleted = 0, completedAt = NULL 
                                        WHERE reminderId = ?";
                $stmt6 = mysqli_prepare($con, $updateRecurringQuery);
                mysqli_stmt_bind_param($stmt6, "si", $nextDate, $recurring['reminderId']);
                mysqli_stmt_execute($stmt6);
            }
        }
        
        echo json_encode([
            'success' => true,
            'message' => 'Automatic reminders generated successfully',
            'remindersCreated' => $remindersCreated,
            'notificationsCreated' => $notificationsCreated
        ]);
        
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
