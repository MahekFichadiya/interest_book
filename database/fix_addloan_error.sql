-- Fix AddLoan.php Error - Add Missing totalDailyInterest Column
-- This script adds the missing totalDailyInterest column to the loan table
-- Created: 2025-07-05

-- Step 1: Add totalDailyInterest column to loan table
ALTER TABLE `loan` 
ADD COLUMN IF NOT EXISTS `totalDailyInterest` DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Total accumulated daily interest over time';

-- Step 2: Initialize totalDailyInterest for existing loans
UPDATE loan 
SET totalDailyInterest = 0.00
WHERE totalDailyInterest IS NULL;

-- Step 3: Verify the column was added
DESCRIBE loan;

-- Step 4: Show success message
SELECT 'totalDailyInterest column added successfully!' as Status;
