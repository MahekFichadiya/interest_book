-- ========================================
-- Remove Notification Feature Migration
-- ========================================
-- This script removes all notification and reminder related 
-- database components while preserving SMS and OTP functionality

-- Drop database events first
DROP EVENT IF EXISTS `generate_payment_reminders`;
DROP EVENT IF EXISTS `cleanup_old_notifications`;

-- Drop tables (foreign key constraints will be handled automatically)
DROP TABLE IF EXISTS `notifications`;
DROP TABLE IF EXISTS `reminders`;

-- Note: We are keeping the following tables as they are used for SMS/OTP functionality:
-- - otp_verification (used for forgot password OTP)
-- - Any SMS-related tables or functionality

-- Verification query to check if tables are removed
-- SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
-- WHERE TABLE_SCHEMA = 'om' AND TABLE_NAME IN ('notifications', 'reminders');
