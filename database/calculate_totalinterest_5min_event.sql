-- Database Event for Calculating totalInterest Every Month
-- This event runs every month for production use
-- It adds the monthly interest amount to totalInterest every month
-- Created: 2025-06-16

-- Drop the existing event if it exists
DROP EVENT IF EXISTS `calculate_totalinterest_5min`;
DROP EVENT IF EXISTS `calculate_totalinterest_monthly`;

-- Create the monthly totalInterest calculation event
DELIMITER $$

CREATE EVENT `calculate_totalinterest_monthly`
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP
ON COMPLETION PRESERVE
ENABLE
DO
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE loan_id INT;
    DECLARE loan_start_date DATETIME;
    DECLARE loan_updated_amount DECIMAL(10,2);
    DECLARE loan_rate DECIMAL(5,2);
    DECLARE loan_last_updated DATE;
    DECLARE current_total_interest DECIMAL(10,2);
    DECLARE months_passed INT;
    DECLARE monthly_interest DECIMAL(10,2);
    DECLARE interest_to_add DECIMAL(10,2);
    
    -- Cursor to iterate through all active loans
    DECLARE loan_cursor CURSOR FOR
        SELECT
            loanId,
            startDate,
            updatedAmount,
            rate,
            lastInterestUpdatedAt,
            totalInterest
        FROM loan
        WHERE updatedAmount > 0;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Start processing loans
    OPEN loan_cursor;
    
    loan_loop: LOOP
        FETCH loan_cursor INTO 
            loan_id, 
            loan_start_date, 
            loan_updated_amount, 
            loan_rate, 
            loan_last_updated,
            current_total_interest;
        
        IF done THEN
            LEAVE loan_loop;
        END IF;
        
        -- Calculate monthly interest amount
        SET monthly_interest = ROUND((loan_updated_amount * loan_rate) / 100, 2);
        
        -- Add monthly interest to totalInterest every month
        -- This provides real monthly interest accumulation for production use

        -- Add the monthly interest amount to totalInterest
        UPDATE loan
        SET
            interest = monthly_interest,
            totalInterest = totalInterest + monthly_interest,
            lastInterestUpdatedAt = NOW()
        WHERE loanId = loan_id;
        
    END LOOP;
    
    CLOSE loan_cursor;
    
    -- Monthly interest calculation completed - totalInterest updated for all active loans
    
END$$

DELIMITER ;

-- Show the event status
SHOW EVENTS LIKE 'calculate_totalinterest_monthly';

-- Display current loan status for verification
SELECT 
    loanId,
    amount,
    updatedAmount,
    rate,
    startDate,
    interest,
    totalInterest,
    lastInterestUpdatedAt,
    TIMESTAMPDIFF(MONTH, startDate, NOW()) as months_from_start,
    ROUND((updatedAmount * rate) / 100, 2) as calculated_monthly_interest,
    CASE 
        WHEN lastInterestUpdatedAt IS NULL 
        THEN ROUND((updatedAmount * rate) / 100, 2) * TIMESTAMPDIFF(MONTH, startDate, NOW())
        ELSE totalInterest + (ROUND((updatedAmount * rate) / 100, 2) * TIMESTAMPDIFF(MONTH, COALESCE(lastInterestUpdatedAt, DATE(startDate)), NOW()))
    END as expected_total_interest
FROM loan
WHERE updatedAmount > 0
ORDER BY startDate;

-- Enable event scheduler if not already enabled
SET GLOBAL event_scheduler = ON;

-- Show event scheduler status
SHOW VARIABLES LIKE 'event_scheduler';
