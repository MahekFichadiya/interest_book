<?php

require_once 'email_config.php';

// Check if PHPMailer files exist
if (!file_exists('PHPMailer/PHPMailer.php')) {
    throw new Exception('PHPMailer not found. Please run install_phpmailer.php first.');
}

require_once 'PHPMailer/PHPMailer.php';
require_once 'PHPMailer/SMTP.php';
require_once 'PHPMailer/Exception.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;
use PHPMailer\PHPMailer\Exception;

class EmailSender {
    
    private $mail;
    
    public function __construct() {
        $this->mail = new PHPMailer(true);
        $this->setupSMTP();
    }
    
    private function setupSMTP() {
        try {
            // Server settings
            $this->mail->isSMTP();
            $this->mail->Host       = EmailConfig::$SMTP_HOST;
            $this->mail->SMTPAuth   = true;
            $this->mail->Username   = EmailConfig::$SMTP_USERNAME;
            $this->mail->Password   = EmailConfig::$SMTP_PASSWORD;
            $this->mail->SMTPSecure = EmailConfig::$SMTP_SECURE;
            $this->mail->Port       = EmailConfig::$SMTP_PORT;
            
            // Content settings
            $this->mail->isHTML(EmailConfig::$IS_HTML);
            $this->mail->CharSet = EmailConfig::$CHARSET;
            
            // Sender
            $this->mail->setFrom(EmailConfig::$FROM_EMAIL, EmailConfig::$FROM_NAME);
            
            // Debug settings (disable in production)
            $this->mail->SMTPDebug = 0; // Set to 2 for debugging
            
        } catch (Exception $e) {
            throw new Exception("SMTP setup failed: " . $e->getMessage());
        }
    }
    
    public function sendOTP($toEmail, $otp) {
        try {
            // Clear any previous recipients
            $this->mail->clearAddresses();
            
            // Recipient
            $this->mail->addAddress($toEmail);
            
            // Get email template
            $template = EmailConfig::getOTPEmailTemplate($otp, $toEmail);
            
            // Content
            $this->mail->Subject = $template['subject'];
            $this->mail->Body    = $template['body'];
            
            // Alternative text body for non-HTML email clients
            $textTemplate = EmailConfig::getOTPTextTemplate($otp, $toEmail);
            $this->mail->AltBody = $textTemplate['body'];
            
            // Send email
            $result = $this->mail->send();
            
            if ($result) {
                return [
                    'success' => true,
                    'message' => 'OTP sent successfully to ' . $toEmail
                ];
            } else {
                return [
                    'success' => false,
                    'message' => 'Failed to send email'
                ];
            }
            
        } catch (Exception $e) {
            error_log("Email sending failed: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Email sending failed: ' . $e->getMessage()
            ];
        }
    }
    
    public function testConnection() {
        try {
            // Test SMTP connection without sending email
            $this->mail->smtpConnect();
            $this->mail->smtpClose();
            
            return [
                'success' => true,
                'message' => 'SMTP connection successful'
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'message' => 'SMTP connection failed: ' . $e->getMessage()
            ];
        }
    }
}

// Function to send OTP (for backward compatibility)
function sendOTPEmail($email, $otp) {
    try {
        $emailSender = new EmailSender();
        return $emailSender->sendOTP($email, $otp);
    } catch (Exception $e) {
        error_log("OTP Email Error: " . $e->getMessage());
        return [
            'success' => false,
            'message' => 'Email system error: ' . $e->getMessage()
        ];
    }
}

?>
