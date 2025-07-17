<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: PUT, POST');
header('Access-Control-Allow-Headers: Content-Type');

include 'Connection.php';

if ($_SERVER['REQUEST_METHOD'] == 'PUT' || $_SERVER['REQUEST_METHOD'] == 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    // Validate required fields
    if (!isset($input['reminderId']) || !isset($input['userId'])) {
        echo json_encode([
            'success' => false,
            'message' => 'Missing required fields: reminderId, userId'
        ]);
        exit;
    }
    
    $reminderId = $input['reminderId'];
    $userId = $input['userId'];
    
    try {
        // Verify reminder belongs to user
        $checkQuery = "SELECT reminderId FROM reminders WHERE reminderId = ? AND userId = ?";
        $stmt = mysqli_prepare($con, $checkQuery);
        mysqli_stmt_bind_param($stmt, "ii", $reminderId, $userId);
        mysqli_stmt_execute($stmt);
        $result = mysqli_stmt_get_result($stmt);
        
        if (mysqli_num_rows($result) == 0) {
            echo json_encode([
                'success' => false,
                'message' => 'Reminder not found or access denied'
            ]);
            exit;
        }
        
        // Build update query dynamically
        $updateFields = [];
        $params = [];
        $types = "";
        
        if (isset($input['reminderTitle'])) {
            $updateFields[] = "reminderTitle = ?";
            $params[] = $input['reminderTitle'];
            $types .= "s";
        }
        
        if (isset($input['reminderMessage'])) {
            $updateFields[] = "reminderMessage = ?";
            $params[] = $input['reminderMessage'];
            $types .= "s";
        }
        
        if (isset($input['reminderDate'])) {
            $updateFields[] = "reminderDate = ?";
            $params[] = $input['reminderDate'];
            $types .= "s";
        }
        
        if (isset($input['reminderTime'])) {
            $updateFields[] = "reminderTime = ?";
            $params[] = $input['reminderTime'];
            $types .= "s";
        }
        
        if (isset($input['isRecurring'])) {
            $updateFields[] = "isRecurring = ?";
            $params[] = $input['isRecurring'];
            $types .= "i";
        }
        
        if (isset($input['recurringInterval'])) {
            $updateFields[] = "recurringInterval = ?";
            $params[] = $input['recurringInterval'];
            $types .= "s";
        }
        
        if (isset($input['isActive'])) {
            $updateFields[] = "isActive = ?";
            $params[] = $input['isActive'];
            $types .= "i";
        }
        
        if (isset($input['isCompleted'])) {
            $updateFields[] = "isCompleted = ?";
            $params[] = $input['isCompleted'];
            $types .= "i";
            
            if ($input['isCompleted'] == 1) {
                $updateFields[] = "completedAt = NOW()";
            }
        }
        
        if (empty($updateFields)) {
            echo json_encode([
                'success' => false,
                'message' => 'No fields to update'
            ]);
            exit;
        }
        
        // Add reminderId and userId to params
        $params[] = $reminderId;
        $params[] = $userId;
        $types .= "ii";
        
        $updateQuery = "UPDATE reminders SET " . implode(", ", $updateFields) . " WHERE reminderId = ? AND userId = ?";
        $stmt = mysqli_prepare($con, $updateQuery);
        mysqli_stmt_bind_param($stmt, $types, ...$params);
        
        if (mysqli_stmt_execute($stmt)) {
            echo json_encode([
                'success' => true,
                'message' => 'Reminder updated successfully'
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to update reminder: ' . mysqli_error($con)
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
