-- Check Existing Foreign Keys and Add Missing Ones
-- Run these commands one by one in your MySQL client
-- Date: 2025-06-28

-- First, let's check what foreign key constraints already exist
-- Run these SHOW CREATE TABLE commands to see existing constraints:

SHOW CREATE TABLE loan;
-- Look for CONSTRAINT lines in the output

SHOW CREATE TABLE interest;
-- Look for CONSTRAINT lines in the output

SHOW CREATE TABLE deposite;
-- Look for CONSTRAINT lines in the output

-- Based on the error, fk_loan_customer already exists, so skip Step 1

-- Step 2: Try to add foreign key for interest -> loan
-- (Only run if not already present in SHOW CREATE TABLE interest output)
ALTER TABLE `interest` 
ADD CONSTRAINT `fk_interest_loan` 
FOREIGN KEY (`loanId`) REFERENCES `loan`(`loanId`) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- Step 3: Try to add foreign key for deposite -> loan
-- (Only run if not already present in SHOW CREATE TABLE deposite output)
ALTER TABLE `deposite` 
ADD CONSTRAINT `fk_deposite_loan` 
FOREIGN KEY (`loanid`) REFERENCES `loan`(`loanId`) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- Step 4: Try to add foreign key for loan -> user
-- (Only run if not already present in SHOW CREATE TABLE loan output)
ALTER TABLE `loan` 
ADD CONSTRAINT `fk_loan_user` 
FOREIGN KEY (`userId`) REFERENCES `user`(`userId`) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- Step 5: Try to add foreign key for customer -> user
-- (Only run if not already present in SHOW CREATE TABLE customer output)
ALTER TABLE `customer` 
ADD CONSTRAINT `fk_customer_user` 
FOREIGN KEY (`userId`) REFERENCES `user`(`userId`) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- Final verification - run these to see all constraints:
SHOW CREATE TABLE loan;
SHOW CREATE TABLE interest;
SHOW CREATE TABLE deposite;
SHOW CREATE TABLE customer;
