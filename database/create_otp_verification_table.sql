-- Create OTP Verification Table
-- This script creates the missing otp_verification table required for OTP functionality
-- Date: 2025-06-28
-- Purpose: Fix the "Table 'omsql.otp_verification' doesn't exist" error

-- Create the otp_verification table
CREATE TABLE IF NOT EXISTS `otp_verification` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `otp_code` varchar(6) NOT NULL,
  `expires_at` datetime NOT NULL,
  `is_used` tinyint(1) NOT NULL DEFAULT 0,
  `attempts` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_email` (`email`),
  KEY `idx_otp_code` (`otp_code`),
  KEY `idx_expires_at` (`expires_at`),
  KEY `idx_email_otp` (`email`, `otp_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Add a cleanup event to automatically delete expired OTP records
-- This will run every hour and delete OTP records older than 24 hours
DELIMITER $$
CREATE EVENT IF NOT EXISTS `cleanup_expired_otp`
ON SCHEDULE EVERY 1 HOUR
STARTS CURRENT_TIMESTAMP
ON COMPLETION PRESERVE
ENABLE
DO
BEGIN
    DELETE FROM otp_verification 
    WHERE created_at < DATE_SUB(NOW(), INTERVAL 24 HOUR);
END$$
DELIMITER ;

-- Enable the event scheduler if not already enabled
SET GLOBAL event_scheduler = ON;

-- Display success message
SELECT 'OTP verification table created successfully' AS Status;

-- Show the table structure
DESCRIBE `otp_verification`;
