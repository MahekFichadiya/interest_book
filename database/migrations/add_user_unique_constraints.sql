-- Migration: Add unique constraints to user table for email and mobile number
-- This prevents duplicate user registrations at the database level
-- Date: 2024-06-24

-- Add unique constraint for email
ALTER TABLE `user` 
ADD CONSTRAINT `unique_email` UNIQUE (`email`);

-- Add unique constraint for mobile number  
ALTER TABLE `user`
ADD CONSTRAINT `unique_mobile` UNIQUE (`mobileNo`);

-- Note: If there are existing duplicate records, this migration will fail.
-- In that case, you need to clean up duplicates first:
-- 
-- To find duplicates by email:
-- SELECT email, COUNT(*) as count FROM user GROUP BY email HAVING count > 1;
--
-- To find duplicates by mobile:
-- SELECT mobileNo, COUNT(*) as count FROM user GROUP BY mobileNo HAVING count > 1;
--
-- Remove duplicates keeping the latest record:
-- DELETE u1 FROM user u1
-- INNER JOIN user u2 
-- WHERE u1.userId < u2.userId 
-- AND (u1.email = u2.email OR u1.mobileNo = u2.mobileNo);
