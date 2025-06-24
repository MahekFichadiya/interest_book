-- Trigger to automatically calculate totalInterest when a new loan is inserted
-- This trigger checks if the start date is more than 1 day old and immediately calculates totalInterest
-- Created: 2025-06-15

-- Drop the trigger if it already exists
DROP TRIGGER IF EXISTS `calculate_totalinterest_on_loan_insert`;

-- Create the trigger using BEFORE INSERT to set values directly
DELIMITER $$

CREATE TRIGGER `calculate_totalinterest_on_loan_insert`
BEFORE INSERT ON `loan`
FOR EACH ROW
BEGIN
    DECLARE days_passed INT;
    DECLARE months_passed INT;
    DECLARE monthly_interest DECIMAL(10,2);
    DECLARE total_interest_to_add DECIMAL(10,2);

    -- Calculate days passed since start date
    SET days_passed = DATEDIFF(CURDATE(), DATE(NEW.startDate));

    -- Only proceed if more than 1 day has passed
    IF days_passed > 1 THEN
        -- Calculate monthly interest amount
        SET monthly_interest = ROUND((NEW.updatedAmount * NEW.rate) / 100, 2);

        -- Calculate months passed (for totalInterest calculation)
        SET months_passed = TIMESTAMPDIFF(MONTH, NEW.startDate, NOW());

        -- If at least 1 month has passed, calculate totalInterest
        IF months_passed >= 1 THEN
            SET total_interest_to_add = monthly_interest * months_passed;

            -- Set the values directly in the NEW record
            SET NEW.interest = monthly_interest;
            SET NEW.totalInterest = total_interest_to_add;
            SET NEW.lastInterestUpdatedAt = CURDATE();
        ELSE
            -- If less than 1 month but more than 1 day, just set the monthly interest
            SET NEW.interest = monthly_interest;
            SET NEW.lastInterestUpdatedAt = CURDATE();
        END IF;
    END IF;
END$$

DELIMITER ;

-- Test the trigger by showing existing loans that would be affected
SELECT 
    loanId,
    amount,
    rate,
    startDate,
    updatedAmount,
    interest,
    totalInterest,
    DATEDIFF(CURDATE(), DATE(startDate)) as days_passed,
    TIMESTAMPDIFF(MONTH, startDate, NOW()) as months_passed,
    ROUND((updatedAmount * rate) / 100, 2) as calculated_monthly_interest,
    CASE 
        WHEN TIMESTAMPDIFF(MONTH, startDate, NOW()) >= 1 
        THEN ROUND((updatedAmount * rate) / 100, 2) * TIMESTAMPDIFF(MONTH, startDate, NOW())
        ELSE 0
    END as calculated_total_interest
FROM loan 
WHERE DATEDIFF(CURDATE(), DATE(startDate)) > 1
ORDER BY startDate;

-- Show trigger status
SHOW TRIGGERS LIKE 'calculate_totalinterest_on_loan_insert';
