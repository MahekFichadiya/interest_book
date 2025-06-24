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
    -- Simple monthly interest calculation for all active loans
    -- Add monthly interest to totalInterest and update tracking fields
    UPDATE loan
    SET
        interest = ROUND((updatedAmount * rate) / 100, 2),
        totalInterest = totalInterest + ROUND((updatedAmount * rate) / 100, 2),
        lastInterestUpdatedAt = NOW()
    WHERE updatedAmount > 0;

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
    ROUND((updatedAmount * rate) / 100, 2) as calculated_monthly_interest
FROM loan
WHERE updatedAmount > 0
ORDER BY startDate;

-- Enable event scheduler if not already enabled
SET GLOBAL event_scheduler = ON;

-- Show event scheduler status
SHOW VARIABLES LIKE 'event_scheduler';
