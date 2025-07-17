<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: PUT, POST');
header('Access-Control-Allow-Headers: Content-Type');

include 'Connection.php';

if ($_SERVER['REQUEST_METHOD'] == 'PUT' || $_SERVER['REQUEST_METHOD'] == 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    // Validate required fields
    if (!isset($input['notificationId']) || !isset($input['userId'])) {
        echo json_encode([
            'success' => false,
            'message' => 'Missing required fields: notificationId, userId'
        ]);
        exit;
    }
    
    $notificationId = $input['notificationId'];
    $userId = $input['userId'];
    
    try {
        // Verify notification belongs to user
        $checkQuery = "SELECT notificationId FROM notifications WHERE notificationId = ? AND userId = ?";
        $stmt = mysqli_prepare($con, $checkQuery);
        mysqli_stmt_bind_param($stmt, "ii", $notificationId, $userId);
        mysqli_stmt_execute($stmt);
        $result = mysqli_stmt_get_result($stmt);
        
        if (mysqli_num_rows($result) == 0) {
            echo json_encode([
                'success' => false,
                'message' => 'Notification not found or access denied'
            ]);
            exit;
        }
        
        // Build update query dynamically
        $updateFields = [];
        $params = [];
        $types = "";
        
        if (isset($input['isRead'])) {
            $updateFields[] = "isRead = ?";
            $params[] = $input['isRead'];
            $types .= "i";
            
            if ($input['isRead'] == 1) {
                $updateFields[] = "readAt = NOW()";
            }
        }
        
        if (isset($input['title'])) {
            $updateFields[] = "title = ?";
            $params[] = $input['title'];
            $types .= "s";
        }
        
        if (isset($input['message'])) {
            $updateFields[] = "message = ?";
            $params[] = $input['message'];
            $types .= "s";
        }
        
        if (isset($input['priority'])) {
            $updateFields[] = "priority = ?";
            $params[] = $input['priority'];
            $types .= "s";
        }
        
        if (empty($updateFields)) {
            echo json_encode([
                'success' => false,
                'message' => 'No fields to update'
            ]);
            exit;
        }
        
        // Add notificationId and userId to params
        $params[] = $notificationId;
        $params[] = $userId;
        $types .= "ii";
        
        $updateQuery = "UPDATE notifications SET " . implode(", ", $updateFields) . " WHERE notificationId = ? AND userId = ?";
        $stmt = mysqli_prepare($con, $updateQuery);
        mysqli_stmt_bind_param($stmt, $types, ...$params);
        
        if (mysqli_stmt_execute($stmt)) {
            echo json_encode([
                'success' => true,
                'message' => 'Notification updated successfully'
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to update notification: ' . mysqli_error($con)
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
        'message' => 'Only PUT/POST method allowed'
    ]);
}

mysqli_close($con);
?>
