# Monthly Interest Calculation System

## Overview
This system automatically calculates and stores monthly interest for all active loans in the `interest` field of the loan table. The system ensures that the monthly interest amount is always current and accurately reflects the remaining loan balance.

## Database Schema

### Loan Table Fields
- `interest` (DECIMAL(10,2)): Stores the current monthly interest amount
- `totalInterest` (DECIMAL(10,2)): Accumulates total interest over time
- `lastInterestUpdatedAt` (DATE): Tracks when interest was last calculated
- `updatedAmount` (INT): Current loan balance after deposits
- `rate` (FLOAT): Monthly interest rate percentage

## Calculation Logic

### Monthly Interest Formula
```
monthlyInterest = updatedAmount * (rate / 100)
```

### Example Calculation
- Loan Amount: ₹100,000
- Monthly Rate: 1.5%
- Deposits Made: ₹20,000
- Updated Amount: ₹80,000
- Monthly Interest: ₹80,000 × (1.5/100) = ₹1,200

## System Components

### Backend APIs

#### 1. `updateMonthlyInterest.php`
- **Purpose**: Updates the `interest` field for all active loans
- **Frequency**: Called before displaying loan data
- **Logic**: Calculates current monthly interest based on remaining balance

#### 2. `automaticInterestCalculation.php`
- **Purpose**: Accumulates interest to `totalInterest` field
- **Frequency**: Called monthly or when time has passed
- **Logic**: Adds monthly interest to total accumulated interest

#### 3. `calculateMonthlyInterest.php`
- **Purpose**: Calculates interest for a specific loan
- **Usage**: Individual loan interest calculation
- **Parameters**: `loanId`

### Frontend Integration

#### LoanProvider Updates
```dart
Future<void> fetchLoanDetailList(String? userId, String? custId) async {
  // 1. Update monthly interest for current calculations
  await interestApi().updateMonthlyInterest();
  
  // 2. Trigger automatic interest accumulation
  await interestApi().triggerAutomaticInterestCalculation();
  
  // 3. Fetch updated loan data
  _loanDetail = await getLoanDetail().loanList(userId, custId);
}
```

### Database Triggers

#### 1. Update After Deposit
```sql
CREATE TRIGGER `update_monthly_interest_after_deposit`
AFTER INSERT ON `deposite`
FOR EACH ROW
BEGIN
    UPDATE loan 
    SET interest = ROUND((updatedAmount * rate) / 100, 2)
    WHERE loanId = NEW.loanId;
END
```

#### 2. Update After Loan Modification
```sql
CREATE TRIGGER `update_monthly_interest_after_loan_update`
AFTER UPDATE ON `loan`
FOR EACH ROW
BEGIN
    IF NEW.updatedAmount != OLD.updatedAmount OR NEW.rate != OLD.rate THEN
        UPDATE loan 
        SET interest = ROUND((NEW.updatedAmount * NEW.rate) / 100, 2)
        WHERE loanId = NEW.loanId;
    END IF;
END
```

### Automated Events

#### Daily Interest Update
```sql
CREATE EVENT `update_monthly_interest_daily`
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    UPDATE loan 
    SET interest = ROUND((updatedAmount * rate) / 100, 2)
    WHERE (endDate IS NULL OR endDate > CURDATE()) 
    AND updatedAmount > 0;
END
```

## Implementation Steps

### 1. Database Setup
```bash
# Run the migration script
mysql -u username -p database_name < database/ensure_monthly_interest_calculation.sql
```

### 2. Backend Deployment
1. Upload all PHP files to your XAMPP server
2. Ensure proper database connection in `Connection.php`
3. Test the APIs using Postman or similar tool

### 3. Frontend Integration
The Flutter code is already updated. Rebuild your app:
```bash
flutter clean
flutter pub get
flutter run
```

## How It Works

### Scenario 1: New Loan Creation
1. Loan created with amount ₹50,000 at 2% monthly rate
2. `interest` field set to ₹1,000 (50,000 × 2%)
3. `totalInterest` starts at ₹0

### Scenario 2: Deposit Made
1. Customer deposits ₹10,000
2. `updatedAmount` becomes ₹40,000
3. Trigger automatically updates `interest` to ₹800 (40,000 × 2%)

### Scenario 3: Monthly Interest Accumulation
1. One month passes since loan creation
2. System adds ₹800 to `totalInterest`
3. `lastInterestUpdatedAt` updated to current date
4. `interest` field remains ₹800 (current monthly amount)

## API Responses

### Success Response
```json
{
  "status": "success",
  "message": "Monthly interest updated for all active loans",
  "data": {
    "totalActiveLoans": 5,
    "loansUpdated": 5,
    "updateDate": "2025-06-14 10:30:00",
    "loansProcessed": [
      {
        "loanId": 63,
        "remainingBalance": 70000,
        "interestRate": 1.5,
        "monthlyInterest": 1050.00,
        "previousInterest": 1200.00
      }
    ]
  }
}
```

### Error Response
```json
{
  "status": "error",
  "message": "Failed to update monthly interest",
  "errorDetails": {
    "file": "/path/to/updateMonthlyInterest.php",
    "line": 45,
    "timestamp": "2025-06-14 10:30:00"
  }
}
```

## Monitoring and Maintenance

### Check Interest Calculation
```sql
SELECT 
    loanId,
    updatedAmount,
    rate,
    interest as stored_interest,
    ROUND((updatedAmount * rate) / 100, 2) as calculated_interest,
    CASE 
        WHEN interest = ROUND((updatedAmount * rate) / 100, 2) THEN 'CORRECT'
        ELSE 'NEEDS_UPDATE'
    END as status
FROM loan 
WHERE updatedAmount > 0;
```

### Manual Interest Update
```sql
CALL UpdateMonthlyInterestForAllLoans();
```

## Benefits

1. **Real-time Accuracy**: Interest field always reflects current monthly amount
2. **Automatic Updates**: Triggers ensure consistency when deposits are made
3. **Separation of Concerns**: Monthly interest vs. accumulated interest
4. **Performance**: Pre-calculated values improve UI responsiveness
5. **Audit Trail**: Clear tracking of when interest was last calculated

## Troubleshooting

### Issue: Interest field shows 0
**Solution**: Run the migration script to update all loans
```sql
UPDATE loan SET interest = ROUND((updatedAmount * rate) / 100, 2) WHERE updatedAmount > 0;
```

### Issue: Interest not updating after deposits
**Solution**: Check if triggers are enabled
```sql
SHOW TRIGGERS LIKE 'update_monthly_interest%';
```

### Issue: API returning errors
**Solution**: Check PHP error logs and database connection
