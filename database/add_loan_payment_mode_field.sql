-- Add payment mode field to loan table
-- This script adds a paymentMode field to the loan table to track payment method (cash/online)
-- Created: 2025-06-28

-- Step 1: Add paymentMode column to loan table
ALTER TABLE `loan` 
ADD COLUMN IF NOT EXISTS `paymentMode` VARCHAR(10) NOT NULL DEFAULT 'cash' COMMENT 'Payment method: cash or online';

-- Step 2: Update existing records to have default value 'cash' for paymentMode
UPDATE `loan` 
SET `paymentMode` = 'cash' 
WHERE `paymentMode` IS NULL OR `paymentMode` = '';

-- Step 3: Also add paymentMode to historyloan table for consistency
ALTER TABLE `historyloan` 
ADD COLUMN IF NOT EXISTS `paymentMode` VARCHAR(10) NOT NULL DEFAULT 'cash' COMMENT 'Payment method: cash or online';

-- Step 4: Update existing records in historyloan table
UPDATE `historyloan` 
SET `paymentMode` = 'cash' 
WHERE `paymentMode` IS NULL OR `paymentMode` = '';

-- Step 5: Update the backup trigger to include paymentMode field
DROP TRIGGER IF EXISTS `backupedLoan`;

DELIMITER $$
CREATE TRIGGER `backupedLoan` AFTER DELETE ON `loan` FOR EACH ROW 
BEGIN
    INSERT INTO historyloan (loanId, amount, rate, startDate, endDate, image, note, updatedAmount, type, userId, custId, paymentMode)
    VALUES (OLD.loanId, OLD.amount, OLD.rate, OLD.startDate, OLD.endDate, OLD.image, OLD.note, OLD.updatedAmount, OLD.type, OLD.userId, OLD.custId, OLD.paymentMode);
END$$
DELIMITER ;

-- Step 6: Show final table structure
DESCRIBE `loan`;

-- Step 7: Show sample data to verify structure
SELECT loanId, amount, paymentMode FROM `loan` LIMIT 5;
