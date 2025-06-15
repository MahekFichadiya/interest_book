-- Migration to fix interest calculation and add proper monthly interest calculation
-- Run this script on your MySQL database

-- First, drop the existing event if it exists
DROP EVENT IF EXISTS `update_interest_every_10_min`;

-- Create a new event for monthly interest calculation
-- This will run daily and calculate interest based on remaining balance
DELIMITER $$

CREATE EVENT `calculate_monthly_interest_daily`
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
ON COMPLETION PRESERVE
ENABLE
DO
BEGIN
    -- Update interest for active loans only
    -- Calculate interest on remaining balance (updatedAmount)
    UPDATE loan 
    SET 
        interest = ROUND((updatedAmount * rate) / 100, 2),
        totalInterest = totalInterest + ROUND((updatedAmount * rate) / 100, 2),
        lastInterestUpdatedAt = CURDATE()
    WHERE 
        (endDate IS NULL OR endDate > CURDATE())
        AND updatedAmount > 0
        AND (lastInterestUpdatedAt IS NULL OR lastInterestUpdatedAt < CURDATE());
END$$

DELIMITER ;

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_loan_enddate ON loan(endDate);
CREATE INDEX IF NOT EXISTS idx_loan_lastinterest ON loan(lastInterestUpdatedAt);
CREATE INDEX IF NOT EXISTS idx_deposite_loanid ON deposite(loanId);
CREATE INDEX IF NOT EXISTS idx_interest_loanid ON interest(loanId);

-- Update existing loans to set proper updatedAmount if not set
UPDATE loan 
SET updatedAmount = amount - COALESCE(totalDeposite, 0)
WHERE updatedAmount = 0 OR updatedAmount IS NULL;

-- Ensure totalDeposite is properly calculated
UPDATE loan l
SET totalDeposite = COALESCE((
    SELECT SUM(depositeAmount) 
    FROM deposite d 
    WHERE d.loanId = l.loanId
), 0);

-- Recalculate updatedAmount based on deposits
UPDATE loan l
SET updatedAmount = GREATEST(0, amount - totalDeposite);
