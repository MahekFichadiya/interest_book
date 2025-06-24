-- Migration: Add Interest Payment Deduction Trigger
-- This script adds a database trigger to automatically deduct interest payments from totalInterest
-- Date: 2025-06-18
-- Purpose: Ensure interest payments are deducted from totalInterest field at database level

-- Check if trigger already exists and drop it if it does
DROP TRIGGER IF EXISTS `deduct_interest_payment`;

-- Create the trigger to automatically deduct interest payments from totalInterest
DELIMITER $$

CREATE TRIGGER `deduct_interest_payment`
AFTER INSERT ON `interest`
FOR EACH ROW
BEGIN
    -- Deduct the interest payment from totalInterest
    -- Using GREATEST to ensure totalInterest never goes below 0
    UPDATE loan 
    SET totalInterest = GREATEST(0, totalInterest - NEW.interestAmount)
    WHERE loanId = NEW.loanId;
END$$

DELIMITER ;

-- Verify the trigger was created successfully
SHOW TRIGGERS LIKE 'deduct_interest_payment';

-- Display success message
SELECT 'Interest payment deduction trigger added successfully' AS Status;
