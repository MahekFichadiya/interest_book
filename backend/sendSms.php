<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

include 'Connection.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    // Validate required fields
    if (!isset($input['userId']) || !isset($input['customerPhone']) || !isset($input['message'])) {
        echo json_encode([
            'success' => false,
            'message' => 'Missing required fields: userId, customerPhone, message'
        ]);
        exit;
    }
    
    $userId = $input['userId'];
    $customerPhone = $input['customerPhone'];
    $message = $input['message'];
    $messageType = isset($input['messageType']) ? $input['messageType'] : 'custom';
    
    try {
        // Log SMS in database
        $logQuery = "INSERT INTO sms_log (userId, customerPhone, message, messageType, status) VALUES (?, ?, ?, ?, 'pending')";
        $stmt = mysqli_prepare($con, $logQuery);
        mysqli_stmt_bind_param($stmt, "isss", $userId, $customerPhone, $message, $messageType);
        
        if (mysqli_stmt_execute($stmt)) {
            $smsLogId = mysqli_insert_id($con);
            
            // Send SMS using your preferred SMS gateway
            $smsResult = sendSmsMessage($customerPhone, $message);
            
            if ($smsResult['success']) {
                // Update log status to sent
                $updateQuery = "UPDATE sms_log SET status = 'sent', sentAt = NOW() WHERE smsLogId = ?";
                $updateStmt = mysqli_prepare($con, $updateQuery);
                mysqli_stmt_bind_param($updateStmt, "i", $smsLogId);
                mysqli_stmt_execute($updateStmt);
                
                echo json_encode([
                    'success' => true,
                    'message' => 'SMS sent successfully',
                    'smsLogId' => $smsLogId,
                    'gatewayResponse' => $smsResult['response']
                ]);
            } else {
                // Update log status to failed
                $updateQuery = "UPDATE sms_log SET status = 'failed', errorMessage = ? WHERE smsLogId = ?";
                $updateStmt = mysqli_prepare($con, $updateQuery);
                mysqli_stmt_bind_param($updateStmt, "si", $smsResult['error'], $smsLogId);
                mysqli_stmt_execute($updateStmt);
                
                echo json_encode([
                    'success' => false,
                    'message' => 'Failed to send SMS: ' . $smsResult['error'],
                    'smsLogId' => $smsLogId
                ]);
            }
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to log SMS: ' . mysqli_error($con)
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

/**
 * Send SMS using SMS gateway
 * You can integrate with any SMS service like:
 * - Twilio
 * - TextLocal
 * - MSG91
 * - Fast2SMS
 * - etc.
 */
function sendSmsMessage($phone, $message) {
    // Example using a generic SMS gateway
    // Replace this with your actual SMS gateway integration
    
    // Method 1: Using TextLocal (Popular in India)
    return sendViaTextLocal($phone, $message);
    
    // Method 2: Using MSG91
    // return sendViaMSG91($phone, $message);
    
    // Method 3: Using Fast2SMS
    // return sendViaFast2SMS($phone, $message);
}

/**
 * TextLocal SMS Gateway Integration
 */
function sendViaTextLocal($phone, $message) {
    try {
        // TextLocal API credentials (you need to register and get these)
        $apiKey = 'YOUR_TEXTLOCAL_API_KEY'; // Replace with your API key
        $sender = 'OMJWLR'; // Replace with your sender ID (6 chars)
        
        // Format phone number
        $phone = formatPhoneNumber($phone);
        
        $postData = array(
            'apikey' => $apiKey,
            'numbers' => $phone,
            'message' => $message,
            'sender' => $sender
        );
        
        $url = 'https://api.textlocal.in/send/';
        
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($postData));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        if ($httpCode == 200) {
            $result = json_decode($response, true);
            if ($result['status'] == 'success') {
                return [
                    'success' => true,
                    'response' => $result
                ];
            } else {
                return [
                    'success' => false,
                    'error' => $result['errors'][0]['message'] ?? 'Unknown error'
                ];
            }
        } else {
            return [
                'success' => false,
                'error' => 'HTTP Error: ' . $httpCode
            ];
        }
        
    } catch (Exception $e) {
        return [
            'success' => false,
            'error' => 'Exception: ' . $e->getMessage()
        ];
    }
}

/**
 * MSG91 SMS Gateway Integration (Alternative)
 */
function sendViaMSG91($phone, $message) {
    try {
        $authKey = 'YOUR_MSG91_AUTH_KEY'; // Replace with your auth key
        $senderId = 'OMJWLR'; // Replace with your sender ID
        $route = 4; // Transactional route
        
        $phone = formatPhoneNumber($phone);
        
        $postData = array(
            'authkey' => $authKey,
            'mobiles' => $phone,
            'message' => $message,
            'sender' => $senderId,
            'route' => $route
        );
        
        $url = 'https://api.msg91.com/api/sendhttp.php';
        
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($postData));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        if ($httpCode == 200) {
            return [
                'success' => true,
                'response' => $response
            ];
        } else {
            return [
                'success' => false,
                'error' => 'HTTP Error: ' . $httpCode
            ];
        }
        
    } catch (Exception $e) {
        return [
            'success' => false,
            'error' => 'Exception: ' . $e->getMessage()
        ];
    }
}

/**
 * Format phone number for SMS
 */
function formatPhoneNumber($phone) {
    // Remove all non-digit characters
    $cleanPhone = preg_replace('/[^\d]/', '', $phone);
    
    // If starts with +91, remove it
    if (substr($cleanPhone, 0, 2) == '91' && strlen($cleanPhone) == 12) {
        $cleanPhone = substr($cleanPhone, 2);
    }
    
    // Ensure 10 digits and add country code
    if (strlen($cleanPhone) == 10) {
        return '91' . $cleanPhone;
    }
    
    return $cleanPhone;
}

mysqli_close($con);
?>
