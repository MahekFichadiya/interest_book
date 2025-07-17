<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

include 'Connection.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $userId = isset($_GET['userId']) ? $_GET['userId'] : null;
    $isRead = isset($_GET['isRead']) ? $_GET['isRead'] : null;
    $notificationType = isset($_GET['notificationType']) ? $_GET['notificationType'] : null;
    $priority = isset($_GET['priority']) ? $_GET['priority'] : null;
    $limit = isset($_GET['limit']) ? intval($_GET['limit']) : 50;
    $offset = isset($_GET['offset']) ? intval($_GET['offset']) : 0;
    
    if (!$userId) {
        echo json_encode([
            'success' => false,
            'message' => 'userId is required'
        ]);
        exit;
    }
    
    try {
        // Build query based on filters
        $query = "SELECT n.*, c.custName, c.custPhn, l.amount as loanAmount, l.type as loanType, r.reminderTitle 
                  FROM notifications n 
                  LEFT JOIN customer c ON n.custId = c.custId 
                  LEFT JOIN loan l ON n.loanId = l.loanId 
                  LEFT JOIN reminders r ON n.reminderId = r.reminderId 
                  WHERE n.userId = ?";
        
        $params = [$userId];
        $types = "i";
        
        if ($isRead !== null) {
            $query .= " AND n.isRead = ?";
            $params[] = $isRead;
            $types .= "i";
        }
        
        if ($notificationType) {
            $query .= " AND n.notificationType = ?";
            $params[] = $notificationType;
            $types .= "s";
        }
        
        if ($priority) {
            $query .= " AND n.priority = ?";
            $params[] = $priority;
            $types .= "s";
        }
        
        $query .= " ORDER BY n.createdAt DESC LIMIT ? OFFSET ?";
        $params[] = $limit;
        $params[] = $offset;
        $types .= "ii";
        
        $stmt = mysqli_prepare($con, $query);
        mysqli_stmt_bind_param($stmt, $types, ...$params);
        mysqli_stmt_execute($stmt);
        $result = mysqli_stmt_get_result($stmt);
        
        $notifications = [];
        while ($row = mysqli_fetch_assoc($result)) {
            $notifications[] = [
                'notificationId' => $row['notificationId'],
                'custId' => $row['custId'],
                'custName' => $row['custName'],
                'custPhn' => $row['custPhn'],
                'loanId' => $row['loanId'],
                'loanAmount' => $row['loanAmount'],
                'loanType' => $row['loanType'],
                'reminderId' => $row['reminderId'],
                'reminderTitle' => $row['reminderTitle'],
                'notificationType' => $row['notificationType'],
                'title' => $row['title'],
                'message' => $row['message'],
                'isRead' => $row['isRead'],
                'isActionRequired' => $row['isActionRequired'],
                'actionType' => $row['actionType'],
                'actionData' => $row['actionData'],
                'priority' => $row['priority'],
                'scheduledAt' => $row['scheduledAt'],
                'readAt' => $row['readAt'],
                'createdAt' => $row['createdAt'],
                'updatedAt' => $row['updatedAt']
            ];
        }
        
        // Get unread count
        $countQuery = "SELECT COUNT(*) as unreadCount FROM notifications WHERE userId = ? AND isRead = 0";
        $stmt2 = mysqli_prepare($con, $countQuery);
        mysqli_stmt_bind_param($stmt2, "i", $userId);
        mysqli_stmt_execute($stmt2);
        $countResult = mysqli_stmt_get_result($stmt2);
        $unreadCount = mysqli_fetch_assoc($countResult)['unreadCount'];
        
        echo json_encode([
            'success' => true,
            'notifications' => $notifications,
            'count' => count($notifications),
            'unreadCount' => $unreadCount
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
        'message' => 'Only GET method allowed'
    ]);
}

mysqli_close($con);
?>
