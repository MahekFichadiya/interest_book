<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

include 'Connection.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $userId = isset($_GET['userId']) ? $_GET['userId'] : null;
    $custId = isset($_GET['custId']) ? $_GET['custId'] : null;
    $isActive = isset($_GET['isActive']) ? $_GET['isActive'] : 1;
    $isCompleted = isset($_GET['isCompleted']) ? $_GET['isCompleted'] : null;
    
    if (!$userId) {
        echo json_encode([
            'success' => false,
            'message' => 'userId is required'
        ]);
        exit;
    }
    
    try {
        // Build query based on filters
        $query = "SELECT r.*, c.custName, c.custPhn, l.amount as loanAmount, l.type as loanType 
                  FROM reminders r 
                  INNER JOIN customer c ON r.custId = c.custId 
                  LEFT JOIN loan l ON r.loanId = l.loanId 
                  WHERE r.userId = ?";
        
        $params = [$userId];
        $types = "i";
        
        if ($custId) {
            $query .= " AND r.custId = ?";
            $params[] = $custId;
            $types .= "i";
        }
        
        if ($isActive !== null) {
            $query .= " AND r.isActive = ?";
            $params[] = $isActive;
            $types .= "i";
        }
        
        if ($isCompleted !== null) {
            $query .= " AND r.isCompleted = ?";
            $params[] = $isCompleted;
            $types .= "i";
        }
        
        $query .= " ORDER BY r.reminderDate ASC, r.reminderTime ASC";
        
        $stmt = mysqli_prepare($con, $query);
        mysqli_stmt_bind_param($stmt, $types, ...$params);
        mysqli_stmt_execute($stmt);
        $result = mysqli_stmt_get_result($stmt);
        
        $reminders = [];
        while ($row = mysqli_fetch_assoc($result)) {
            $reminders[] = [
                'reminderId' => $row['reminderId'],
                'custId' => $row['custId'],
                'custName' => $row['custName'],
                'custPhn' => $row['custPhn'],
                'loanId' => $row['loanId'],
                'loanAmount' => $row['loanAmount'],
                'loanType' => $row['loanType'],
                'reminderType' => $row['reminderType'],
                'reminderTitle' => $row['reminderTitle'],
                'reminderMessage' => $row['reminderMessage'],
                'reminderDate' => $row['reminderDate'],
                'reminderTime' => $row['reminderTime'],
                'isRecurring' => $row['isRecurring'],
                'recurringInterval' => $row['recurringInterval'],
                'isActive' => $row['isActive'],
                'isCompleted' => $row['isCompleted'],
                'completedAt' => $row['completedAt'],
                'createdAt' => $row['createdAt'],
                'updatedAt' => $row['updatedAt']
            ];
        }
        
        echo json_encode([
            'success' => true,
            'reminders' => $reminders,
            'count' => count($reminders)
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
