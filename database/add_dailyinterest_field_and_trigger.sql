-- Add dailyInterest field to loan table and create trigger
-- This script adds a dailyInterest field and automatically calculates it when loans are inserted
-- Created: 2025-06-16

-- Step 1: Add dailyInterest field to loan table
ALTER TABLE `loan` 
ADD COLUMN IF NOT EXISTS `dailyInterest` DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Daily interest amount calculated from monthly interest';

-- Step 2: Update existing loans to calculate dailyInterest
-- Daily interest = (updatedAmount * rate) / 100 / 30
UPDATE loan 
SET dailyInterest = ROUND((updatedAmount * rate) / 100 / 30, 2)
WHERE updatedAmount > 0;

-- Step 3: Drop existing loan insert trigger if it exists
DROP TRIGGER IF EXISTS `calculate_interest_on_loan_insert`;

-- Step 4: Create new trigger to calculate all interest fields when loan is inserted
DELIMITER $$

CREATE TRIGGER `calculate_interest_on_loan_insert`
BEFORE INSERT ON `loan`
FOR EACH ROW
BEGIN
    DECLARE days_passed INT;
    DECLARE months_passed INT;
    DECLARE monthly_interest DECIMAL(10,2);
    DECLARE daily_interest DECIMAL(10,2);
    DECLARE total_interest_to_add DECIMAL(10,2);

    -- Calculate monthly interest: (updatedAmount * rate) / 100
    SET monthly_interest = ROUND((NEW.updatedAmount * NEW.rate) / 100, 2);
    
    -- Calculate daily interest: monthly interest / 30
    SET daily_interest = ROUND(monthly_interest / 30, 2);
    
    -- Set the interest fields
    SET NEW.interest = monthly_interest;
    SET NEW.dailyInterest = daily_interest;
    
    -- Calculate days passed since start date
    SET days_passed = DATEDIFF(CURDATE(), DATE(NEW.startDate));

    -- Only calculate totalInterest if more than 1 day has passed
    IF days_passed > 1 THEN
        -- Calculate months passed (for totalInterest calculation)
        SET months_passed = TIMESTAMPDIFF(MONTH, NEW.startDate, NOW());

        -- If at least 1 month has passed, calculate totalInterest
        IF months_passed >= 1 THEN
            SET total_interest_to_add = monthly_interest * months_passed;
            SET NEW.totalInterest = total_interest_to_add;
            SET NEW.lastInterestUpdatedAt = CURDATE();
        ELSE
            -- If less than 1 month but more than 1 day, set totalInterest to 0
            SET NEW.totalInterest = 0.00;
            SET NEW.lastInterestUpdatedAt = CURDATE();
        END IF;
    ELSE
        -- If 1 day or less has passed, set totalInterest to 0
        SET NEW.totalInterest = 0.00;
    END IF;
END$$

DELIMITER ;

-- Step 5: Update existing deposit triggers to also recalculate dailyInterest
-- Drop existing triggers
DROP TRIGGER IF EXISTS `update_loan_after_deposit_insert`;
DROP TRIGGER IF EXISTS `update_loan_after_deposit_update`;
DROP TRIGGER IF EXISTS `update_loan_after_deposit_delete`;

-- Recreate deposit insert trigger with dailyInterest calculation
DELIMITER $$
CREATE TRIGGER `update_loan_after_deposit_insert`
AFTER INSERT ON `deposite`
FOR EACH ROW
BEGIN
    DECLARE total_deposits DECIMAL(10,2);
    DECLARE loan_amount DECIMAL(10,2);
    DECLARE loan_rate DECIMAL(5,2);
    DECLARE new_updated_amount DECIMAL(10,2);
    DECLARE new_monthly_interest DECIMAL(10,2);
    DECLARE new_daily_interest DECIMAL(10,2);
    
    -- Get current loan details
    SELECT amount, rate INTO loan_amount, loan_rate
    FROM loan 
    WHERE loanId = NEW.loanid;
    
    -- Calculate total deposits for this loan
    SELECT COALESCE(SUM(depositeAmount), 0) INTO total_deposits
    FROM deposite 
    WHERE loanid = NEW.loanid;
    
    -- Calculate new updated amount (remaining balance)
    SET new_updated_amount = GREATEST(0, loan_amount - total_deposits);
    
    -- Calculate new monthly interest on remaining balance
    SET new_monthly_interest = ROUND((new_updated_amount * loan_rate) / 100, 2);
    
    -- Calculate new daily interest
    SET new_daily_interest = ROUND(new_monthly_interest / 30, 2);
    
    -- Update loan table with all calculated values
    UPDATE loan 
    SET 
        totalDeposite = total_deposits,
        updatedAmount = new_updated_amount,
        interest = new_monthly_interest,
        dailyInterest = new_daily_interest
    WHERE loanId = NEW.loanid;
END$$

DELIMITER ;

-- Recreate deposit update trigger with dailyInterest calculation
DELIMITER $$
CREATE TRIGGER `update_loan_after_deposit_update`
AFTER UPDATE ON `deposite`
FOR EACH ROW
BEGIN
    DECLARE total_deposits DECIMAL(10,2);
    DECLARE loan_amount DECIMAL(10,2);
    DECLARE loan_rate DECIMAL(5,2);
    DECLARE new_updated_amount DECIMAL(10,2);
    DECLARE new_monthly_interest DECIMAL(10,2);
    DECLARE new_daily_interest DECIMAL(10,2);
    
    -- Get current loan details
    SELECT amount, rate INTO loan_amount, loan_rate
    FROM loan 
    WHERE loanId = NEW.loanid;
    
    -- Calculate total deposits for this loan
    SELECT COALESCE(SUM(depositeAmount), 0) INTO total_deposits
    FROM deposite 
    WHERE loanid = NEW.loanid;
    
    -- Calculate new updated amount (remaining balance)
    SET new_updated_amount = GREATEST(0, loan_amount - total_deposits);
    
    -- Calculate new monthly interest on remaining balance
    SET new_monthly_interest = ROUND((new_updated_amount * loan_rate) / 100, 2);
    
    -- Calculate new daily interest
    SET new_daily_interest = ROUND(new_monthly_interest / 30, 2);
    
    -- Update loan table with all calculated values
    UPDATE loan 
    SET 
        totalDeposite = total_deposits,
        updatedAmount = new_updated_amount,
        interest = new_monthly_interest,
        dailyInterest = new_daily_interest
    WHERE loanId = NEW.loanid;
END$$

DELIMITER ;

-- Recreate deposit delete trigger with dailyInterest calculation
DELIMITER $$
CREATE TRIGGER `update_loan_after_deposit_delete`
AFTER DELETE ON `deposite`
FOR EACH ROW
BEGIN
    DECLARE total_deposits DECIMAL(10,2);
    DECLARE loan_amount DECIMAL(10,2);
    DECLARE loan_rate DECIMAL(5,2);
    DECLARE new_updated_amount DECIMAL(10,2);
    DECLARE new_monthly_interest DECIMAL(10,2);
    DECLARE new_daily_interest DECIMAL(10,2);
    
    -- Get current loan details
    SELECT amount, rate INTO loan_amount, loan_rate
    FROM loan 
    WHERE loanId = OLD.loanid;
    
    -- Calculate total deposits for this loan (after deletion)
    SELECT COALESCE(SUM(depositeAmount), 0) INTO total_deposits
    FROM deposite 
    WHERE loanid = OLD.loanid;
    
    -- Calculate new updated amount (remaining balance)
    SET new_updated_amount = GREATEST(0, loan_amount - total_deposits);
    
    -- Calculate new monthly interest on remaining balance
    SET new_monthly_interest = ROUND((new_updated_amount * loan_rate) / 100, 2);
    
    -- Calculate new daily interest
    SET new_daily_interest = ROUND(new_monthly_interest / 30, 2);
    
    -- Update loan table with all calculated values
    UPDATE loan 
    SET 
        totalDeposite = total_deposits,
        updatedAmount = new_updated_amount,
        interest = new_monthly_interest,
        dailyInterest = new_daily_interest
    WHERE loanId = OLD.loanid;
END$$

DELIMITER ;

-- Step 6: Show current loan data with all interest calculations
SELECT 
    loanId,
    amount,
    updatedAmount,
    rate,
    startDate,
    interest as monthly_interest,
    dailyInterest as daily_interest,
    totalInterest,
    lastInterestUpdatedAt,
    ROUND((updatedAmount * rate) / 100, 2) as calculated_monthly,
    ROUND((updatedAmount * rate) / 100 / 30, 2) as calculated_daily
FROM loan 
WHERE updatedAmount > 0
ORDER BY startDate;

-- Step 7: Show all triggers related to loan table
SHOW TRIGGERS WHERE `Table` = 'loan';

-- Step 8: Verify the new column was added
DESCRIBE loan;
