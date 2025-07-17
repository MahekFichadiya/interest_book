<?php

// Email Configuration for OTP Sending
// Update these settings with your email provider details

class EmailConfig {
    
    // SMTP Settings - Choose your email provider
    
    // For Gmail (recommended for testing)
    public static $SMTP_HOST = 'smtp.gmail.com';
    public static $SMTP_PORT = 587;
    public static $SMTP_SECURE = 'tls'; // 'tls' or 'ssl'
    
    // Your email credentials
    public static $SMTP_USERNAME = 'mahekfichadiya@gmail.com'; // Your Gmail address
    public static $SMTP_PASSWORD = 'yevj lysz wauu farr';    // Your Gmail App Password (not regular password)
    
    // Sender information
    public static $FROM_EMAIL = 'mahekfichadiya@gmail.com';    // Same as SMTP_USERNAME
    public static $FROM_NAME = 'Interest Book App';        // Your app name
    
    // Email settings
    public static $IS_HTML = true;
    public static $CHARSET = 'UTF-8';
    
    /* 
    ALTERNATIVE EMAIL PROVIDERS:
    
    // For Outlook/Hotmail
    public static $SMTP_HOST = 'smtp-mail.outlook.com';
    public static $SMTP_PORT = 587;
    public static $SMTP_SECURE = 'tls';
    
    // For Yahoo
    public static $SMTP_HOST = 'smtp.mail.yahoo.com';
    public static $SMTP_PORT = 587;
    public static $SMTP_SECURE = 'tls';
    
    // For custom SMTP (like your hosting provider)
    public static $SMTP_HOST = 'mail.yourdomain.com';
    public static $SMTP_PORT = 587;
    public static $SMTP_SECURE = 'tls';
    */
    
    // OTP Email Template
    public static function getOTPEmailTemplate($otp, $email) {
        return [
            'subject' => 'Password Reset OTP - Interest Book',
            'body' => "
                <html>
                <head>
                    <style>
                        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                        .header { background: #607D8B; color: white; padding: 20px; text-align: center; border-radius: 5px 5px 0 0; }
                        .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 5px 5px; }
                        .otp-box { background: #fff; border: 2px solid #607D8B; padding: 20px; text-align: center; margin: 20px 0; border-radius: 5px; }
                        .otp-code { font-size: 32px; font-weight: bold; color: #607D8B; letter-spacing: 5px; }
                        .footer { text-align: center; margin-top: 20px; font-size: 12px; color: #666; }
                        .warning { background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 5px; margin: 15px 0; }
                    </style>
                </head>
                <body>
                    <div class='container'>
                        <div class='header'>
                            <h1>Interest Book App</h1>
                            <p>Password Reset Request</p>
                        </div>
                        <div class='content'>
                            <h2>Hello!</h2>
                            <p>You have requested to reset your password for your Interest Book account.</p>
                            <p>Your One-Time Password (OTP) is:</p>
                            
                            <div class='otp-box'>
                                <div class='otp-code'>$otp</div>
                                <p><strong>Valid for 15 minutes</strong></p>
                            </div>
                            
                            <div class='warning'>
                                <strong>Security Notice:</strong>
                                <ul style='margin: 10px 0; padding-left: 20px;'>
                                    <li>This OTP is valid for 15 minutes only</li>
                                    <li>Do not share this OTP with anyone</li>
                                    <li>If you didn't request this, please ignore this email</li>
                                </ul>
                            </div>
                            
                            <p>If you have any questions, please contact our support team.</p>
                            
                            <p>Best regards,<br>
                            <strong>Interest Book Team</strong></p>
                        </div>
                        <div class='footer'>
                            <p>This is an automated email. Please do not reply to this email.</p>
                            <p>© 2024 Interest Book App. All rights reserved.</p>
                        </div>
                    </div>
                </body>
                </html>
            "
        ];
    }
    
    // Simple text version for email clients that don't support HTML
    public static function getOTPTextTemplate($otp, $email) {
        return [
            'subject' => 'Password Reset OTP - Interest Book',
            'body' => "
Interest Book App - Password Reset

Hello!

You have requested to reset your password for your Interest Book account.

Your One-Time Password (OTP) is: $otp

This OTP is valid for 15 minutes only.

Security Notice:
- Do not share this OTP with anyone
- If you didn't request this, please ignore this email

Best regards,
Interest Book Team

This is an automated email. Please do not reply.
            "
        ];
    }
}

?>
