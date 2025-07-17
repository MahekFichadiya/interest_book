-- Fix deposit table structure and column issues
-- This script ensures the deposite table has the correct structure
-- Created: 2025-06-27

-- Step 1: Check current table structure
DESCRIBE `deposite`;

-- Step 2: Add depositeField column if it doesn't exist
ALTER TABLE `deposite` 
ADD COLUMN IF NOT EXISTS `depositeField` VARCHAR(10) NOT NULL DEFAULT 'cash' COMMENT 'Payment method: cash or online';

-- Step 3: Update existing records to have default value 'cash' for depositeField
UPDATE `deposite` 
SET `depositeField` = 'cash' 
WHERE `depositeField` IS NULL OR `depositeField` = '';

-- Step 4: Ensure the loanid column exists (it should already exist)
-- Note: The column name in the database is 'loanid' (lowercase), not 'loanId'

-- Step 5: Show final table structure
DESCRIBE `deposite`;

-- Step 6: Show sample data to verify structure
SELECT * FROM `deposite` LIMIT 5;

-- Step 7: Test insert query (this is what the PHP backend uses)
-- Uncomment the line below to test (replace with actual values)
-- INSERT INTO deposite (depositeAmount, depositeDate, depositeNote, loanid, depositeField) VALUES (100, '2025-06-27', 'Test deposit', 1, 'cash');
