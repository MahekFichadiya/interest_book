-- Simple Foreign Key Constraints Setup
-- Run these commands one by one in your MySQL client
-- Date: 2025-06-28
-- Purpose: Add foreign key constraints for cascading deletion

-- IMPORTANT: The cascading deletion is already implemented in PHP code
-- These constraints are optional and provide database-level backup

-- Step 1: Add foreign key for loan -> customer
-- (Skip if you get "Duplicate key name" error)
ALTER TABLE `loan` 
ADD CONSTRAINT `fk_loan_customer` 
FOREIGN KEY (`custId`) REFERENCES `customer`(`custId`) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- Step 2: Add foreign key for interest -> loan  
-- (Skip if you get "Duplicate key name" error)
ALTER TABLE `interest` 
ADD CONSTRAINT `fk_interest_loan` 
FOREIGN KEY (`loanId`) REFERENCES `loan`(`loanId`) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- Step 3: Add foreign key for deposite -> loan
-- (Skip if you get "Duplicate key name" error)
ALTER TABLE `deposite` 
ADD CONSTRAINT `fk_deposite_loan` 
FOREIGN KEY (`loanid`) REFERENCES `loan`(`loanId`) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- Optional: Add user relationship constraints
-- (Skip if you get "Duplicate key name" error)
ALTER TABLE `loan` 
ADD CONSTRAINT `fk_loan_user` 
FOREIGN KEY (`userId`) REFERENCES `user`(`userId`) 
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `customer` 
ADD CONSTRAINT `fk_customer_user` 
FOREIGN KEY (`userId`) REFERENCES `user`(`userId`) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- Verification commands (run these to check if constraints were added):
SHOW CREATE TABLE loan;
SHOW CREATE TABLE interest;
SHOW CREATE TABLE deposite;
