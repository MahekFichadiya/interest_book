-- Setup Automatic Interest Calculation System
-- Run this script to set up the complete automatic interest calculation system

-- Step 1: Ensure all required columns exist
ALTER TABLE `loan` 
ADD COLUMN IF NOT EXISTS `interest` DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Monthly interest amount',
ADD COLUMN IF NOT EXISTS `totalInterest` DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Total accumulated interest',
ADD COLUMN IF NOT EXISTS `lastInterestUpdatedAt` DATE DEFAULT NULL COMMENT 'Last date when interest was calculated';

-- Step 2: Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_loan_enddate ON loan(endDate);
CREATE INDEX IF NOT EXISTS idx_loan_lastinterest ON loan(lastInterestUpdatedAt);
CREATE INDEX IF NOT EXISTS idx_loan_updated_amount ON loan(updatedAmount);
CREATE INDEX IF NOT EXISTS idx_deposite_loanid ON deposite(loanId);
CREATE INDEX IF NOT EXISTS idx_interest_loanid ON interest(loanId);

-- Step 3: Fix existing data
-- Update existing loans to set proper updatedAmount if not set
UPDATE loan 
SET updatedAmount = amount - COALESCE(totalDeposite, 0)
WHERE updatedAmount = 0 OR updatedAmount IS NULL;

-- Ensure totalDeposite is properly calculated for existing loans
UPDATE loan l
SET totalDeposite = COALESCE((
    SELECT SUM(depositeAmount) 
    FROM deposite d 
    WHERE d.loanId = l.loanId
), 0);

-- Calculate initial monthly interest for all existing loans
UPDATE loan 
SET interest = ROUND((updatedAmount * rate) / 100, 2)
WHERE updatedAmount > 0;

-- Step 4: Drop existing events and triggers if they exist
DROP EVENT IF EXISTS `calculate_monthly_interest_daily`;
DROP EVENT IF EXISTS `update_interest_every_10_min`;
DROP TRIGGER IF EXISTS `recalculate_interest_after_deposit`;
DROP TRIGGER IF EXISTS `deduct_interest_payment`;

-- Step 5: Create the main automatic interest calculation event
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

-- Step 6: Create trigger to recalculate interest when deposits are made
DELIMITER $$

CREATE TRIGGER `recalculate_interest_after_deposit`
AFTER INSERT ON `deposite`
FOR EACH ROW
BEGIN
    DECLARE remaining_balance DECIMAL(10,2);
    DECLARE loan_rate DECIMAL(5,2);
    DECLARE new_monthly_interest DECIMAL(10,2);
    
    -- Get the updated loan details
    SELECT updatedAmount, rate INTO remaining_balance, loan_rate
    FROM loan 
    WHERE loanId = NEW.loanId;
    
    -- Calculate new monthly interest on remaining balance
    SET new_monthly_interest = ROUND((remaining_balance * loan_rate) / 100, 2);
    
    -- Update the monthly interest field
    UPDATE loan 
    SET interest = new_monthly_interest
    WHERE loanId = NEW.loanId;
END$$

DELIMITER ;

-- Step 7: Create trigger to deduct interest payments from totalInterest
DELIMITER $$

CREATE TRIGGER `deduct_interest_payment`
AFTER INSERT ON `interest`
FOR EACH ROW
BEGIN
    -- Deduct the interest payment from totalInterest
    UPDATE loan 
    SET totalInterest = GREATEST(0, totalInterest - NEW.interestAmount)
    WHERE loanId = NEW.loanId;
END$$

DELIMITER ;

-- Step 8: Initialize interest calculation for existing loans
-- Set lastInterestUpdatedAt to today for all existing loans
UPDATE loan 
SET lastInterestUpdatedAt = CURDATE()
WHERE lastInterestUpdatedAt IS NULL;

-- Step 9: Enable the event scheduler
SET GLOBAL event_scheduler = ON;

-- Step 10: Run initial interest calculation for all active loans
UPDATE loan 
SET 
    interest = ROUND((updatedAmount * rate) / 100, 2),
    totalInterest = totalInterest + ROUND((updatedAmount * rate) / 100, 2),
    lastInterestUpdatedAt = CURDATE()
WHERE 
    (endDate IS NULL OR endDate > CURDATE())
    AND updatedAmount > 0
    AND totalInterest = 0;

-- Show setup completion status
SELECT 'Automatic Interest Calculation System Setup Complete!' AS Status;
SELECT COUNT(*) AS 'Active Loans with Interest Calculation' 
FROM loan 
WHERE (endDate IS NULL OR endDate > CURDATE()) AND updatedAmount > 0;

SELECT 
    loanId,
    amount,
    updatedAmount,
    rate,
    interest AS 'Monthly Interest',
    totalInterest AS 'Total Interest',
    lastInterestUpdatedAt AS 'Last Updated'
FROM loan 
WHERE (endDate IS NULL OR endDate > CURDATE()) AND updatedAmount > 0
LIMIT 5;
