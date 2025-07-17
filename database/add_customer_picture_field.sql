-- Migration to add customer picture field to customer and historycustomer tables
-- Run this script on existing databases to add the custPic field
-- This script is safe to run multiple times as it checks for column existence

-- Add custPic field to customer table (only if it doesn't exist)
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE()
     AND TABLE_NAME = 'customer'
     AND COLUMN_NAME = 'custPic') = 0,
    'ALTER TABLE `customer` ADD COLUMN `custPic` varchar(255) DEFAULT NULL AFTER `custAddress`',
    'SELECT "Column custPic already exists in customer table" AS message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add custPic field to historycustomer table (only if it doesn't exist)
SET @sql = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE()
     AND TABLE_NAME = 'historycustomer'
     AND COLUMN_NAME = 'custPic') = 0,
    'ALTER TABLE `historycustomer` ADD COLUMN `custPic` varchar(255) DEFAULT NULL AFTER `custAddress`',
    'SELECT "Column custPic already exists in historycustomer table" AS message'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Update the backup trigger to include custPic field
DROP TRIGGER IF EXISTS `backupedCustomer`;

DELIMITER $$
CREATE TRIGGER `backupedCustomer` AFTER DELETE ON `customer` FOR EACH ROW BEGIN
    INSERT INTO historycustomer (custId, custName, custPhn, custAddress, custPic, date, userId)
    VALUES (OLD.custId, OLD.custName, OLD.custPhn, OLD.custAddress, OLD.custPic, OLD.date, OLD.userId);
END
$$
DELIMITER ;
