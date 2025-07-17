-- Migration: Add payment method columns to interest and deposite tables
-- This script adds the missing payment method columns to store payment method (cash/online)
-- Date: 2025-06-28
-- Purpose: Fix the "Unknown column 'interestField'" and 'depositeField' errors

-- Add the interestField column to the interest table
ALTER TABLE `interest`
ADD COLUMN IF NOT EXISTS `interestField` VARCHAR(20) NOT NULL DEFAULT 'cash'
COMMENT 'Payment method for interest payment (cash/online)';

-- Add the depositeField column to the deposite table
ALTER TABLE `deposite`
ADD COLUMN IF NOT EXISTS `depositeField` VARCHAR(20) NOT NULL DEFAULT 'cash'
COMMENT 'Payment method for deposit (cash/online)';

-- Update existing records to have default value 'cash'
UPDATE `interest`
SET `interestField` = 'cash'
WHERE `interestField` IS NULL OR `interestField` = '';

UPDATE `deposite`
SET `depositeField` = 'cash'
WHERE `depositeField` IS NULL OR `depositeField` = '';

-- Verify the columns were added successfully
DESCRIBE `interest`;
DESCRIBE `deposite`;

-- Display success message
SELECT 'Payment method columns added successfully to interest and deposite tables' AS Status;
