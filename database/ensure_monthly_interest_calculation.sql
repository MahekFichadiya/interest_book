-- Ensure Monthly Interest Calculation System
-- This script ensures that the monthly interest calculation is working properly
-- and that the 'interest' field in the loan table stores the current monthly interest amount

-- Step 1: Ensure all required columns exist in the loan table
ALTER TABLE `loan` 
ADD COLUMN IF NOT EXISTS `interest` DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Monthly interest amount',
ADD COLUMN IF NOT EXISTS `totalInterest` DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Total accumulated interest',
ADD COLUMN IF NOT EXISTS `lastInterestUpdatedAt` DATE DEFAULT NULL COMMENT 'Last date when interest was calculated';

-- Step 2: Update the monthly interest for all existing loans
-- This ensures the 'interest' field contains the current monthly interest amount
UPDATE loan 
SET interest = ROUND((updatedAmount * rate) / 100, 2)
WHERE updatedAmount > 0;

-- Step 3: Create or replace the trigger to update monthly interest when deposits are made
DROP TRIGGER IF EXISTS `update_monthly_interest_after_deposit`;

DELIMITER $$

CREATE TRIGGER `update_monthly_interest_after_deposit`
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

-- Step 4: Create or replace the trigger to update monthly interest when loan amount is updated
DROP TRIGGER IF EXISTS `update_monthly_interest_after_loan_update`;

DELIMITER $$

CREATE TRIGGER `update_monthly_interest_after_loan_update`
AFTER UPDATE ON `loan`
FOR EACH ROW
BEGIN
    DECLARE new_monthly_interest DECIMAL(10,2);
    
    -- Only update if updatedAmount or rate has changed
    IF NEW.updatedAmount != OLD.updatedAmount OR NEW.rate != OLD.rate THEN
        -- Calculate new monthly interest
        SET new_monthly_interest = ROUND((NEW.updatedAmount * NEW.rate) / 100, 2);
        
        -- Update the monthly interest field
        UPDATE loan 
        SET interest = new_monthly_interest
        WHERE loanId = NEW.loanId;
    END IF;
END$$

DELIMITER ;

-- Step 5: Create a stored procedure to manually update monthly interest for all loans
DROP PROCEDURE IF EXISTS `UpdateMonthlyInterestForAllLoans`;

DELIMITER $$

CREATE PROCEDURE `UpdateMonthlyInterestForAllLoans`()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE loan_id INT;
    DECLARE updated_amount DECIMAL(10,2);
    DECLARE loan_rate DECIMAL(5,2);
    DECLARE monthly_interest DECIMAL(10,2);
    
    -- Cursor to iterate through all active loans
    DECLARE loan_cursor CURSOR FOR 
        SELECT loanId, updatedAmount, rate
        FROM loan 
        WHERE (endDate IS NULL OR endDate > CURDATE()) 
        AND updatedAmount > 0;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN loan_cursor;
    
    loan_loop: LOOP
        FETCH loan_cursor INTO loan_id, updated_amount, loan_rate;
        
        IF done THEN
            LEAVE loan_loop;
        END IF;
        
        -- Calculate monthly interest
        SET monthly_interest = ROUND((updated_amount * loan_rate) / 100, 2);
        
        -- Update the loan
        UPDATE loan 
        SET interest = monthly_interest
        WHERE loanId = loan_id;
        
    END LOOP;
    
    CLOSE loan_cursor;
END$$

DELIMITER ;

-- Step 6: Create an event to automatically update monthly interest daily
DROP EVENT IF EXISTS `update_monthly_interest_daily`;

DELIMITER $$

CREATE EVENT `update_monthly_interest_daily`
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
ON COMPLETION PRESERVE
ENABLE
DO
BEGIN
    -- Update monthly interest for all active loans
    UPDATE loan 
    SET interest = ROUND((updatedAmount * rate) / 100, 2)
    WHERE (endDate IS NULL OR endDate > CURDATE()) 
    AND updatedAmount > 0;
END$$

DELIMITER ;

-- Step 7: Enable the event scheduler
SET GLOBAL event_scheduler = ON;

-- Step 8: Run the initial update to ensure all loans have correct monthly interest
CALL UpdateMonthlyInterestForAllLoans();

-- Step 9: Display summary of updated loans
SELECT 
    COUNT(*) as total_active_loans,
    SUM(CASE WHEN interest > 0 THEN 1 ELSE 0 END) as loans_with_interest,
    AVG(interest) as average_monthly_interest,
    SUM(interest) as total_monthly_interest
FROM loan 
WHERE (endDate IS NULL OR endDate > CURDATE()) 
AND updatedAmount > 0;

-- Step 10: Show sample of updated loans
SELECT 
    loanId,
    updatedAmount,
    rate,
    interest as monthly_interest,
    totalInterest,
    ROUND((updatedAmount * rate) / 100, 2) as calculated_interest,
    CASE 
        WHEN interest = ROUND((updatedAmount * rate) / 100, 2) THEN 'CORRECT'
        ELSE 'NEEDS_UPDATE'
    END as status
FROM loan 
WHERE (endDate IS NULL OR endDate > CURDATE()) 
AND updatedAmount > 0
LIMIT 10;
