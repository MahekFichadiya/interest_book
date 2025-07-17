# History Loan Documents System

## Overview
This system provides comprehensive document management for historical loans, ensuring that when loans are moved to the `historyloan` table, their associated documents are preserved and accessible.

## Problem Solved
Previously, when loans were deleted or settled:
1. Documents were lost due to foreign key CASCADE deletion
2. No way to access documents for historical loans
3. Image data was stored directly in loan tables (inefficient)

## Solution Architecture

### 1. Tables Structure

#### `history_loan_documents`
```sql
CREATE TABLE `history_loan_documents` (
  `documentId` int(11) NOT NULL AUTO_INCREMENT,
  `loanId` int(5) NOT NULL,           -- References historyloan.loanId
  `documentPath` varchar(255) NOT NULL,
  `archivedDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`documentId`),
  KEY `idx_history_loan_id` (`loanId`),
  KEY `idx_archived_date` (`archivedDate`)
);
```

#### `loan_documents` (Active loans)
```sql
CREATE TABLE `loan_documents` (
  `documentId` int(11) NOT NULL AUTO_INCREMENT,
  `loanId` int(5) NOT NULL,           -- References loan.loanId
  `documentPath` varchar(255) NOT NULL,
  PRIMARY KEY (`documentId`),
  FOREIGN KEY (`loanId`) REFERENCES `loan` (`loanId`) ON DELETE RESTRICT
);
```

#### `historyloan` (Updated structure)
```sql
CREATE TABLE `historyloan` (
  `loanId` int(5) NOT NULL,
  `amount` int(10) NOT NULL,
  `rate` float NOT NULL,
  `startDate` datetime NOT NULL,
  `endDate` date DEFAULT NULL,
  `note` varchar(100) NOT NULL,       -- No more image field
  `updatedAmount` int(10) NOT NULL,
  `type` tinyint(1) NOT NULL,
  `userId` int(5) NOT NULL,
  `custId` int(5) NOT NULL,
  `custName` VARCHAR(100) DEFAULT 'Unknown Customer',
  `paymentMode` VARCHAR(10) NOT NULL DEFAULT 'cash'
);
```

### 2. Automated Document Archiving

#### Trigger: `archive_document_on_delete`
- **NEW**: Automatically archives documents when deleted directly from `loan_documents`
- Triggers on any DELETE operation on `loan_documents` table
- Preserves all document paths with archive timestamp

#### Trigger: `archive_loan_documents_on_delete` (Legacy)
- Automatically moves documents to `history_loan_documents` when a loan is deleted
- Preserves all document paths with archive timestamp

#### Procedure: `CleanupLoanDocuments`
- Safely deletes documents (archiving handled by trigger)
- Ensures transactional integrity
- Updated to work with new trigger system

#### Updated Trigger: `backupedLoan`
- Moves loan data to `historyloan`
- Automatically calls document cleanup
- Preserves customer names

### 3. API Endpoints

#### `getHistoryLoans.php`
**Purpose**: Get all historical loans with document counts
**Method**: GET
**Parameters**: 
- `userId` (required)

**Response**:
```json
{
  "status": "true",
  "historyLoans": [
    {
      "loanId": 123,
      "amount": 50000,
      "custName": "John Doe",
      "documentCount": 3,
      "hasDocuments": true,
      ...
    }
  ],
  "summary": {
    "totalLoans": 25,
    "youGotTotal": 200000,
    "youGaveTotal": 150000,
    "loansWithDocuments": 18,
    "totalDocuments": 45
  }
}
```

#### `getHistoryLoanDocuments.php`
**Purpose**: Get all documents for a specific historical loan
**Method**: GET
**Parameters**:
- `loanId` (required)
- `userId` (required)

**Response**:
```json
{
  "status": "true",
  "loanInfo": {
    "loanId": 123,
    "amount": 50000,
    "custName": "John Doe",
    ...
  },
  "documents": [
    {
      "documentId": 456,
      "documentPath": "OmjavellersHtml/LoanImages/document1.jpg",
      "archivedDate": "2025-07-04 10:30:00",
      "fileName": "document1.jpg"
    }
  ],
  "documentCount": 1
}
```

#### `deleteLoanDocument.php`
**Purpose**: Safely delete a document with automatic archiving
**Method**: POST
**Parameters**:
- `documentId` (required)
- `userId` (required)

**Response**:
```json
{
  "status": "true",
  "message": "Document deleted and archived successfully",
  "deletedDocument": {
    "documentId": 456,
    "loanId": 123,
    "documentPath": "OmjavellersHtml/LoanImages/document1.jpg",
    "fileName": "document1.jpg"
  },
  "archived": true,
  "archiveCount": 1
}
```

## Migration Scripts

### 1. `setup_history_loan_documents.omsql`
- Creates the `history_loan_documents` table
- Sets up triggers and procedures
- Migrates existing historyloan image data

### 2. `migrate_existing_history_data.omsql`
- Handles existing data migration
- Cleans up orphaned documents
- Updates historyloan table structure

### 3. `transfer_loan_images_to_documents.omsql`
- Transfers active loan images to `loan_documents`
- Removes image field from loan table

## Implementation Steps

### Step 1: Setup History System
```sql
source database/setup_history_loan_documents.omsql
```

### Step 2: Migrate Existing Data
```sql
source database/migrate_existing_history_data.omsql
```

### Step 3: Transfer Active Loan Images
```sql
source database/transfer_loan_images_to_documents.omsql
```

## Benefits

### 1. **Document Preservation**
- All loan documents are preserved when loans are archived
- No data loss during loan lifecycle transitions

### 2. **Clean Separation**
- Active loans: `loan_documents` table
- Historical loans: `history_loan_documents` table
- Clear data organization

### 3. **Performance**
- Separate tables prevent large joins
- Indexed for fast retrieval
- Archive timestamps for audit trails

### 4. **Data Integrity**
- Transactional document archiving
- Foreign key constraints where appropriate
- Automatic cleanup procedures

### 5. **API Ready**
- RESTful endpoints for frontend integration
- Comprehensive data retrieval
- Error handling and validation

## Usage Examples

### Frontend Integration
```javascript
// Get all history loans
const historyLoans = await fetch(`/backend/getHistoryLoans.php?userId=${userId}`);

// Get documents for specific loan
const loanDocs = await fetch(`/backend/getHistoryLoanDocuments.php?loanId=${loanId}&userId=${userId}`);
```

### Database Queries
```sql
-- Get history loans with document counts
SELECT hl.*, COUNT(hld.documentId) as docCount
FROM historyloan hl
LEFT JOIN history_loan_documents hld ON hl.loanId = hld.loanId
WHERE hl.userId = ?
GROUP BY hl.loanId;

-- Get all documents for a history loan
SELECT * FROM history_loan_documents 
WHERE loanId = ? 
ORDER BY archivedDate DESC;
```

## Maintenance

### Regular Cleanup (Optional)
```sql
-- Remove very old archived documents (older than 5 years)
DELETE FROM history_loan_documents 
WHERE archivedDate < DATE_SUB(NOW(), INTERVAL 5 YEAR);
```

### Monitoring
```sql
-- Check system health
SELECT 
    'Active Documents' as Type, COUNT(*) as Count 
FROM loan_documents
UNION ALL
SELECT 
    'History Documents' as Type, COUNT(*) as Count 
FROM history_loan_documents;
```

This system ensures complete document lifecycle management while maintaining data integrity and performance.
