-- Migration script to move all loan images from loan.image field to loan_documents table
-- This consolidates all loan documents in one place for better management
-- Created: 2025-06-29

-- Step 1: Insert existing loan images into loan_documents table
INSERT INTO `loan_documents` (`loanId`, `documentPath`, `documentName`, `documentType`, `fileSize`, `uploadDate`)
SELECT 
    `loanId`,
    `image` as `documentPath`,
    CASE 
        WHEN `image` IS NOT NULL AND `image` != '' AND `image` != 'null' 
        THEN SUBSTRING_INDEX(`image`, '/', -1)
        ELSE 'main_document'
    END as `documentName`,
    CASE 
        WHEN `image` LIKE '%.jpg' OR `image` LIKE '%.jpeg' THEN 'image/jpeg'
        WHEN `image` LIKE '%.png' THEN 'image/png'
        WHEN `image` LIKE '%.gif' THEN 'image/gif'
        WHEN `image` LIKE '%.pdf' THEN 'application/pdf'
        WHEN `image` LIKE '%.doc' OR `image` LIKE '%.docx' THEN 'application/msword'
        ELSE 'application/octet-stream'
    END as `documentType`,
    NULL as `fileSize`, -- We don't have file size info for existing images
    NOW() as `uploadDate`
FROM `loan` 
WHERE `image` IS NOT NULL 
  AND `image` != '' 
  AND `image` != 'null'
  AND `loanId` NOT IN (
    -- Avoid duplicates if this script is run multiple times
    SELECT DISTINCT `loanId` 
    FROM `loan_documents` 
    WHERE `documentPath` IN (
      SELECT `image` FROM `loan` WHERE `image` IS NOT NULL AND `image` != '' AND `image` != 'null'
    )
  );

-- Step 2: Verify the migration
SELECT 
    'Migration Summary' as Status,
    COUNT(*) as TotalDocuments,
    COUNT(DISTINCT loanId) as LoansWithDocuments
FROM `loan_documents`;

-- Step 3: Show sample of migrated data
SELECT 
    ld.loanId,
    ld.documentName,
    ld.documentType,
    l.amount,
    l.custId
FROM `loan_documents` ld
JOIN `loan` l ON ld.loanId = l.loanId
ORDER BY ld.uploadDate DESC
LIMIT 10;

-- Step 4: Optional - Clear the image field from loan table after verification
-- UNCOMMENT THE FOLLOWING LINES ONLY AFTER VERIFYING THE MIGRATION IS SUCCESSFUL
/*
UPDATE `loan` SET `image` = NULL WHERE `image` IS NOT NULL;
ALTER TABLE `loan` DROP COLUMN `image`;
*/

-- Step 5: Show final status
SELECT 'Migration completed successfully. Please verify the data before clearing the image field.' as Message;
