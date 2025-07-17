-- Fix Double Deduction/Addition Issue in Loan Deposits
-- This script corrects any loans that may have been affected by double deduction (on insert) or double addition (on delete)
-- Date: 2025-06-28
-- Purpose: Recalculate updatedAmount and totalDeposite for all loans based on actual deposits

-- Step 1: Show current loan status before fix
SELECT 
    loanId,
    amount as original_amount,
    updatedAmount as current_updated_amount,
    totalDeposite as current_total_deposite,
    (amount - COALESCE((SELECT SUM(depositeAmount) FROM deposite WHERE loanid = loan.loanId), 0)) as correct_updated_amount,
    COALESCE((SELECT SUM(depositeAmount) FROM deposite WHERE loanid = loan.loanId), 0) as correct_total_deposite,
    CASE 
        WHEN updatedAmount != (amount - COALESCE((SELECT SUM(depositeAmount) FROM deposite WHERE loanid = loan.loanId), 0))
        THEN 'NEEDS_FIX'
        ELSE 'OK'
    END as status
FROM loan
ORDER BY loanId;

-- Step 2: Fix the double deduction issue by recalculating all loan amounts
UPDATE loan 
SET 
    totalDeposite = COALESCE((
        SELECT SUM(depositeAmount) 
        FROM deposite 
        WHERE loanid = loan.loanId
    ), 0),
    updatedAmount = GREATEST(0, amount - COALESCE((
        SELECT SUM(depositeAmount) 
        FROM deposite 
        WHERE loanid = loan.loanId
    ), 0))
WHERE loanId IN (
    SELECT loanId FROM (
        SELECT loanId 
        FROM loan 
        WHERE updatedAmount != GREATEST(0, amount - COALESCE((
            SELECT SUM(depositeAmount) 
            FROM deposite 
            WHERE loanid = loan.loanId
        ), 0))
    ) as subquery
);

-- Step 3: Recalculate interest based on corrected updatedAmount
UPDATE loan 
SET 
    interest = ROUND((updatedAmount * rate) / 100, 2),
    dailyInterest = ROUND(((updatedAmount * rate) / 100) / 30, 2)
WHERE updatedAmount >= 0;

-- Step 4: Show loan status after fix
SELECT 
    loanId,
    amount as original_amount,
    updatedAmount as corrected_updated_amount,
    totalDeposite as corrected_total_deposite,
    interest as monthly_interest,
    dailyInterest as daily_interest,
    (amount - totalDeposite) as verification_amount
FROM loan
ORDER BY loanId;

-- Step 5: Verification query to ensure all calculations are correct
SELECT 
    'Verification Complete' as status,
    COUNT(*) as total_loans,
    SUM(CASE WHEN updatedAmount = (amount - totalDeposite) THEN 1 ELSE 0 END) as correct_loans,
    SUM(CASE WHEN updatedAmount != (amount - totalDeposite) THEN 1 ELSE 0 END) as incorrect_loans
FROM loan;

-- Display success message
SELECT 'Double deduction/addition issue fixed successfully' AS Status;
