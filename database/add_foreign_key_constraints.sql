-- Add Foreign Key Constraints for Cascading Deletion
-- This script adds proper foreign key constraints to ensure data integrity
-- Date: 2025-06-28
-- Purpose: Implement proper cascading deletion with database-level constraints

-- Note: Run each ALTER TABLE statement one by one
-- If a constraint already exists, you'll get an error which you can ignore

-- Step 2: Add foreign key constraint for loan -> customer relationship
-- This ensures loans are deleted when customer is deleted
ALTER TABLE `loan` 
ADD CONSTRAINT `fk_loan_customer` 
FOREIGN KEY (`custId`) REFERENCES `customer`(`custId`) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- Step 3: Add foreign key constraint for interest -> loan relationship  
-- This ensures interests are deleted when loan is deleted
ALTER TABLE `interest` 
ADD CONSTRAINT `fk_interest_loan` 
FOREIGN KEY (`loanId`) REFERENCES `loan`(`loanId`) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- Step 4: Add foreign key constraint for deposite -> loan relationship
-- This ensures deposits are deleted when loan is deleted
-- Note: Using 'loanid' (lowercase) as that's the actual column name in deposite table
ALTER TABLE `deposite` 
ADD CONSTRAINT `fk_deposite_loan` 
FOREIGN KEY (`loanid`) REFERENCES `loan`(`loanId`) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- Step 5: Add foreign key constraint for loan -> user relationship
-- This ensures data integrity for user relationships
ALTER TABLE `loan` 
ADD CONSTRAINT `fk_loan_user` 
FOREIGN KEY (`userId`) REFERENCES `user`(`userId`) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- Step 6: Add foreign key constraint for customer -> user relationship
-- This ensures data integrity for user relationships
ALTER TABLE `customer` 
ADD CONSTRAINT `fk_customer_user_cascade` 
FOREIGN KEY (`userId`) REFERENCES `user`(`userId`) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- Step 7: Display success message
SELECT 'Foreign key constraints script completed' AS Status;

-- Note: To verify constraints were added, you can run:
-- SHOW CREATE TABLE loan;
-- SHOW CREATE TABLE interest;
-- SHOW CREATE TABLE deposite;
