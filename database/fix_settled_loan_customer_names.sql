-- Fix Settled Loan Customer Names
-- This script adds custName field to historyloan table and updates the backup trigger
-- Date: 2025-06-28
-- Purpose: Ensure customer names are preserved when loans are moved to history

-- Step 1: Add custName column to historyloan table
ALTER TABLE `historyloan` 
ADD COLUMN IF NOT EXISTS `custName` VARCHAR(100) DEFAULT 'Unknown Customer' 
COMMENT 'Customer name preserved from customer table';

-- Step 2: Update existing records in historyloan with customer names
-- First try to get names from customer table
UPDATE `historyloan` h
LEFT JOIN `customer` c ON h.custId = c.custId
SET h.custName = COALESCE(c.custName, h.custName)
WHERE h.custName IS NULL OR h.custName = '' OR h.custName = 'Unknown Customer';

-- Then try to get names from historycustomer table for remaining records
UPDATE `historyloan` h
LEFT JOIN `historycustomer` hc ON h.custId = hc.custId
SET h.custName = COALESCE(hc.custName, h.custName)
WHERE h.custName IS NULL OR h.custName = '' OR h.custName = 'Unknown Customer';

-- Step 3: Update the backup trigger to include customer name
DROP TRIGGER IF EXISTS `backupedLoan`;

DELIMITER $$
CREATE TRIGGER `backupedLoan` AFTER DELETE ON `loan` FOR EACH ROW 
BEGIN
    DECLARE customer_name VARCHAR(100) DEFAULT 'Unknown Customer';
    
    -- Try to get customer name from customer table first
    SELECT custName INTO customer_name
    FROM customer 
    WHERE custId = OLD.custId
    LIMIT 1;
    
    -- If not found, try historycustomer table
    IF customer_name IS NULL OR customer_name = '' THEN
        SELECT custName INTO customer_name
        FROM historycustomer 
        WHERE custId = OLD.custId
        LIMIT 1;
    END IF;
    
    -- If still not found, use default
    IF customer_name IS NULL OR customer_name = '' THEN
        SET customer_name = 'Unknown Customer';
    END IF;
    
    -- Insert into historyloan with customer name
    INSERT INTO historyloan (
        loanId, amount, rate, startDate, endDate, image, note, 
        updatedAmount, type, userId, custId, custName, paymentMode
    )
    VALUES (
        OLD.loanId, OLD.amount, OLD.rate, OLD.startDate, OLD.endDate, OLD.image, OLD.note,
        OLD.updatedAmount, OLD.type, OLD.userId, OLD.custId, customer_name, 
        COALESCE(OLD.paymentMode, 'cash')
    );
END$$
DELIMITER ;

-- Step 4: Verify the changes
SELECT 
    COUNT(*) as total_settled_loans,
    SUM(CASE WHEN custName IS NOT NULL AND custName != 'Unknown Customer' THEN 1 ELSE 0 END) as loans_with_names,
    SUM(CASE WHEN custName IS NULL OR custName = 'Unknown Customer' THEN 1 ELSE 0 END) as loans_without_names
FROM historyloan;

-- Step 5: Show sample of updated records
SELECT loanId, custId, custName, amount, startDate 
FROM historyloan 
ORDER BY startDate DESC 
LIMIT 10;

-- Display success message
SELECT 'Settled loan customer names fixed successfully' AS Status;
