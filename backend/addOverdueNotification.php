<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

include 'Connection.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    // Validate required fields
    if (!isset($input['userId']) || !isset($input['custId']) || !isset($input['reminderId']) || !isset($input['title']) || !isset($input['message'])) {
        echo json_encode([
            'success' => false,
            'message' => 'Missing required fields: userId, custId, reminderId, title, message'
        ]);
        exit;
    }
    
    $userId = $input['userId'];
    $custId = $input['custId'];
    $loanId = isset($input['loanId']) ? $input['loanId'] : null;
    $reminderId = $input['reminderId'];
    $title = $input['title'];
    $message = $input['message'];
    $daysOverdue = isset($input['daysOverdue']) ? $input['daysOverdue'] : 1;
    
    try {
        // Check if overdue notification already exists for today
        $today = date('Y-m-d');
        $checkQuery = "SELECT notificationId FROM notifications 
                       WHERE userId = ? AND custId = ? AND reminderId = ? 
                       AND notificationType = 'reminder' 
                       AND title LIKE '%OVERDUE%' 
                       AND DATE(createdAt) = ?";
        $stmt = mysqli_prepare($con, $checkQuery);
        mysqli_stmt_bind_param($stmt, "iiis", $userId, $custId, $reminderId, $today);
        mysqli_stmt_execute($stmt);
        $result = mysqli_stmt_get_result($stmt);
        
        if (mysqli_num_rows($result) > 0) {
            echo json_encode([
                'success' => true,
                'message' => 'Overdue notification already exists for today',
                'alreadyExists' => true
            ]);
            exit;
        }
        
        // Create overdue notification
        $insertQuery = "INSERT INTO notifications (userId, custId, loanId, reminderId, notificationType, title, message, isActionRequired, actionType, priority) VALUES (?, ?, ?, ?, 'reminder', ?, ?, 1, 'call_customer', 'urgent')";
        $stmt = mysqli_prepare($con, $insertQuery);
        mysqli_stmt_bind_param($stmt, "iiiiss", $userId, $custId, $loanId, $reminderId, $title, $message);
        
        if (mysqli_stmt_execute($stmt)) {
            $notificationId = mysqli_insert_id($con);
            
            echo json_encode([
                'success' => true,
                'message' => 'Overdue notification created successfully',
                'notificationId' => $notificationId,
                'daysOverdue' => $daysOverdue
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to create overdue notification: ' . mysqli_error($con)
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
