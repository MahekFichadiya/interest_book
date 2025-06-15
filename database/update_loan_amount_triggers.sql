-- Triggers to handle updatedAmount and totalDeposite calculations
-- This script creates triggers to automatically update loan balances when:
-- 1. Deposits are added/updated/deleted
-- 2. Loan amounts are updated

-- Drop existing triggers if they exist
DROP TRIGGER IF EXISTS `update_loan_after_deposit_insert`;
DROP TRIGGER IF EXISTS `update_loan_after_deposit_update`;
DROP TRIGGER IF EXISTS `update_loan_after_deposit_delete`;
DROP TRIGGER IF EXISTS `recalculate_interest_after_deposit`;

-- Trigger 1: After deposit is inserted
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
    
    -- Update loan table
    UPDATE loan 
    SET 
        totalDeposite = total_deposits,
        updatedAmount = new_updated_amount,
        interest = new_monthly_interest
    WHERE loanId = NEW.loanid;
END$$
DELIMITER ;

-- Trigger 2: After deposit is updated
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
    
    -- Update loan table
    UPDATE loan 
    SET 
        totalDeposite = total_deposits,
        updatedAmount = new_updated_amount,
        interest = new_monthly_interest
    WHERE loanId = NEW.loanid;
END$$
DELIMITER ;

-- Trigger 3: After deposit is deleted
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
    
    -- Update loan table
    UPDATE loan 
    SET 
        totalDeposite = total_deposits,
        updatedAmount = new_updated_amount,
        interest = new_monthly_interest
    WHERE loanId = OLD.loanid;
END$$
DELIMITER ;

-- Create a stored procedure to recalculate all loan balances
DELIMITER $$
CREATE PROCEDURE `RecalculateAllLoanBalances`()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE loan_id INT;
    DECLARE loan_amount DECIMAL(10,2);
    DECLARE loan_rate DECIMAL(5,2);
    DECLARE total_deposits DECIMAL(10,2);
    DECLARE new_updated_amount DECIMAL(10,2);
    DECLARE new_monthly_interest DECIMAL(10,2);
    
    -- Cursor to iterate through all loans
    DECLARE loan_cursor CURSOR FOR
        SELECT loanId, amount, rate FROM loan;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN loan_cursor;
    
    loan_loop: LOOP
        FETCH loan_cursor INTO loan_id, loan_amount, loan_rate;
        IF done THEN
            LEAVE loan_loop;
        END IF;
        
        -- Calculate total deposits for this loan
        SELECT COALESCE(SUM(depositeAmount), 0) INTO total_deposits
        FROM deposite 
        WHERE loanid = loan_id;
        
        -- Calculate new updated amount (remaining balance)
        SET new_updated_amount = GREATEST(0, loan_amount - total_deposits);
        
        -- Calculate new monthly interest on remaining balance
        SET new_monthly_interest = ROUND((new_updated_amount * loan_rate) / 100, 2);
        
        -- Update loan table
        UPDATE loan 
        SET 
            totalDeposite = total_deposits,
            updatedAmount = new_updated_amount,
            interest = new_monthly_interest
        WHERE loanId = loan_id;
        
    END LOOP;
    
    CLOSE loan_cursor;
END$$
DELIMITER ;

-- Run the procedure to fix any existing data inconsistencies
CALL RecalculateAllLoanBalances();

-- Show completion message
SELECT 'Loan amount update triggers created successfully' AS Status;
SELECT 'All loan balances have been recalculated' AS Message;
