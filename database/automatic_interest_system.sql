-- Automatic Interest Calculation System
-- This script sets up automatic monthly interest calculation for the loan system

-- First, ensure all required fields exist in the loan table
ALTER TABLE `loan` 
ADD COLUMN IF NOT EXISTS `interest` DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Monthly interest amount',
ADD COLUMN IF NOT EXISTS `totalInterest` DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Total accumulated interest',
ADD COLUMN IF NOT EXISTS `lastInterestUpdatedAt` DATE DEFAULT NULL COMMENT 'Last date when interest was calculated';

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_loan_enddate ON loan(endDate);
CREATE INDEX IF NOT EXISTS idx_loan_lastinterest ON loan(lastInterestUpdatedAt);
CREATE INDEX IF NOT EXISTS idx_loan_updated_amount ON loan(updatedAmount);
CREATE INDEX IF NOT EXISTS idx_deposite_loanid ON deposite(loanId);
CREATE INDEX IF NOT EXISTS idx_interest_loanid ON interest(loanId);

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

-- Drop existing events if they exist
DROP EVENT IF EXISTS `calculate_monthly_interest_daily`;
DROP EVENT IF EXISTS `update_interest_every_10_min`;

-- Create the main automatic interest calculation event
-- This runs daily and calculates interest for loans that haven't been updated today
DELIMITER $$

CREATE EVENT `calculate_monthly_interest_daily`
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
ON COMPLETION PRESERVE
ENABLE
DO
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE loan_id INT;
    DECLARE loan_amount DECIMAL(10,2);
    DECLARE loan_rate DECIMAL(5,2);
    DECLARE updated_amount DECIMAL(10,2);
    DECLARE start_date DATE;
    DECLARE last_update DATE;
    DECLARE months_passed INT;
    DECLARE monthly_interest DECIMAL(10,2);
    DECLARE interest_to_add DECIMAL(10,2);
    
    -- Cursor to get all active loans that need interest calculation
    DECLARE loan_cursor CURSOR FOR
        SELECT loanId, amount, rate, updatedAmount, startDate, lastInterestUpdatedAt
        FROM loan 
        WHERE (endDate IS NULL OR endDate > CURDATE())
        AND updatedAmount > 0
        AND (lastInterestUpdatedAt IS NULL OR lastInterestUpdatedAt < CURDATE());
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN loan_cursor;
    
    loan_loop: LOOP
        FETCH loan_cursor INTO loan_id, loan_amount, loan_rate, updated_amount, start_date, last_update;
        
        IF done THEN
            LEAVE loan_loop;
        END IF;
        
        -- Calculate monthly interest
        SET monthly_interest = ROUND((updated_amount * loan_rate) / 100, 2);
        
        -- Calculate months since last update or loan start
        IF last_update IS NULL THEN
            SET months_passed = TIMESTAMPDIFF(MONTH, start_date, CURDATE());
        ELSE
            SET months_passed = TIMESTAMPDIFF(MONTH, last_update, CURDATE());
        END IF;
        
        -- Only add interest if at least one month has passed
        IF months_passed > 0 THEN
            SET interest_to_add = monthly_interest * months_passed;
            
            -- Update the loan with new interest
            UPDATE loan 
            SET 
                interest = monthly_interest,
                totalInterest = totalInterest + interest_to_add,
                lastInterestUpdatedAt = CURDATE()
            WHERE loanId = loan_id;
        END IF;
        
    END LOOP;
    
    CLOSE loan_cursor;
END$$

DELIMITER ;

-- Create a trigger to automatically calculate interest when deposits are made
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

-- Create a trigger to automatically update totalInterest when interest payments are made
-- Note: This trigger provides database-level backup for interest payment deduction
-- The main deduction logic is handled in addInterest.php API
DELIMITER $$

CREATE TRIGGER IF NOT EXISTS `deduct_interest_payment`
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

-- Initialize interest calculation for existing loans
-- This will set the lastInterestUpdatedAt to today for all existing loans
-- so that future calculations start from today
UPDATE loan 
SET lastInterestUpdatedAt = CURDATE()
WHERE lastInterestUpdatedAt IS NULL;

-- Create a stored procedure for manual interest calculation
DELIMITER $$

CREATE PROCEDURE `CalculateInterestForLoan`(IN loan_id INT)
BEGIN
    DECLARE remaining_balance DECIMAL(10,2);
    DECLARE loan_rate DECIMAL(5,2);
    DECLARE start_date DATE;
    DECLARE last_update DATE;
    DECLARE months_passed INT;
    DECLARE monthly_interest DECIMAL(10,2);
    DECLARE interest_to_add DECIMAL(10,2);
    
    -- Get loan details
    SELECT updatedAmount, rate, startDate, lastInterestUpdatedAt
    INTO remaining_balance, loan_rate, start_date, last_update
    FROM loan 
    WHERE loanId = loan_id;
    
    -- Calculate monthly interest
    SET monthly_interest = ROUND((remaining_balance * loan_rate) / 100, 2);
    
    -- Calculate months since last update or loan start
    IF last_update IS NULL THEN
        SET months_passed = TIMESTAMPDIFF(MONTH, start_date, CURDATE());
    ELSE
        SET months_passed = TIMESTAMPDIFF(MONTH, last_update, CURDATE());
    END IF;
    
    -- Only add interest if at least one month has passed
    IF months_passed > 0 THEN
        SET interest_to_add = monthly_interest * months_passed;
        
        -- Update the loan with new interest
        UPDATE loan 
        SET 
            interest = monthly_interest,
            totalInterest = totalInterest + interest_to_add,
            lastInterestUpdatedAt = CURDATE()
        WHERE loanId = loan_id;
    END IF;
END$$

DELIMITER ;

-- Enable the event scheduler if it's not already enabled
SET GLOBAL event_scheduler = ON;

-- Show status
SELECT 'Automatic Interest Calculation System Setup Complete' AS Status;
SELECT COUNT(*) AS 'Active Loans' FROM loan WHERE (endDate IS NULL OR endDate > CURDATE()) AND updatedAmount > 0;
