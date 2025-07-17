-- Complete Fix for totalDailyInterest Column and Trigger
-- This script adds the column first, then updates the trigger
-- Created: 2025-07-05

-- Step 1: Add totalDailyInterest column to loan table FIRST
ALTER TABLE `loan` 
ADD COLUMN IF NOT EXISTS `totalDailyInterest` DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Total accumulated daily interest over time';

-- Step 2: Initialize totalDailyInterest for existing loans
UPDATE loan 
SET totalDailyInterest = 0.00;

-- Step 3: Verify the column was added
SELECT 'Column added successfully!' as Status;
DESCRIBE loan;

-- Step 4: Now drop the existing trigger
DROP TRIGGER IF EXISTS `calculate_interest_on_loan_insert`;

-- Step 5: Create updated trigger with totalDailyInterest calculation
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
    DECLARE total_daily_interest DECIMAL(10,2);

    -- Calculate monthly interest: (updatedAmount * rate) / 100
    SET monthly_interest = ROUND((NEW.updatedAmount * NEW.rate) / 100, 2);
    
    -- Calculate daily interest: monthly interest / 30
    SET daily_interest = ROUND(monthly_interest / 30, 2);
    
    -- Set the interest fields
    SET NEW.interest = monthly_interest;
    SET NEW.dailyInterest = daily_interest;
    
    -- Calculate days passed since start date
    SET days_passed = DATEDIFF(CURDATE(), DATE(NEW.startDate));

    -- Calculate totalDailyInterest based on days passed
    IF days_passed > 0 THEN
        SET total_daily_interest = ROUND(daily_interest * days_passed, 2);
    ELSE
        SET total_daily_interest = 0.00;
    END IF;
    
    SET NEW.totalDailyInterest = total_daily_interest;

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
            SET NEW.lastInterestUpdatedAt = NULL;
        END IF;
    ELSE
        -- If 1 day or less has passed, set totalInterest to 0
        SET NEW.totalInterest = 0.00;
        SET NEW.lastInterestUpdatedAt = NULL;
    END IF;
END$$

DELIMITER ;

-- Step 6: Verify everything was created successfully
SHOW TRIGGERS WHERE `Table` = 'loan';

-- Step 7: Final success message
SELECT 'Complete fix applied successfully! Column added and trigger updated.' as Status;
