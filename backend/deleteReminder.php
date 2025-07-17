<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: DELETE, POST');
header('Access-Control-Allow-Headers: Content-Type');

include 'Connection.php';

if ($_SERVER['REQUEST_METHOD'] == 'DELETE' || $_SERVER['REQUEST_METHOD'] == 'POST') {
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
        
        // Start transaction
        mysqli_autocommit($con, false);
        
        // Delete related notifications first
        $deleteNotificationsQuery = "DELETE FROM notifications WHERE reminderId = ? AND userId = ?";
        $stmt1 = mysqli_prepare($con, $deleteNotificationsQuery);
        mysqli_stmt_bind_param($stmt1, "ii", $reminderId, $userId);
        mysqli_stmt_execute($stmt1);
        
        // Delete reminder
        $deleteReminderQuery = "DELETE FROM reminders WHERE reminderId = ? AND userId = ?";
        $stmt2 = mysqli_prepare($con, $deleteReminderQuery);
        mysqli_stmt_bind_param($stmt2, "ii", $reminderId, $userId);
        
        if (mysqli_stmt_execute($stmt2)) {
            mysqli_commit($con);
            echo json_encode([
                'success' => true,
                'message' => 'Reminder deleted successfully'
            ]);
        } else {
            mysqli_rollback($con);
            echo json_encode([
                'success' => false,
                'message' => 'Failed to delete reminder: ' . mysqli_error($con)
            ]);
        }
        
        mysqli_autocommit($con, true);
        
    } catch (Exception $e) {
        mysqli_rollback($con);
        mysqli_autocommit($con, true);
        echo json_encode([
            'success' => false,
            'message' => 'Error: ' . $e->getMessage()
        ]);
    }
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Only DELETE/POST method allowed'
    ]);
}

mysqli_close($con);
?>
