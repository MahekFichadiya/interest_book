<?php
// Simple test script to fix the database trigger issue
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "interest_book";

try {
    $pdo = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "Connected to database successfully\n";
    
    // Step 1: Show current triggers
    echo "\n=== Current Triggers ===\n";
    $stmt = $pdo->query("SHOW TRIGGERS LIKE 'loan'");
    $triggers = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($triggers as $trigger) {
        echo "Trigger: " . $trigger['Trigger'] . " - Event: " . $trigger['Event'] . " - Timing: " . $trigger['Timing'] . "\n";
    }
    
    // Step 2: Show loan table structure
    echo "\n=== Loan Table Structure ===\n";
    $stmt = $pdo->query("DESCRIBE loan");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $loanColumns = [];
    foreach ($columns as $column) {
        $loanColumns[] = $column['Field'];
        echo $column['Field'] . " - " . $column['Type'] . "\n";
    }
    
    // Step 3: Show historyloan table structure
    echo "\n=== History Loan Table Structure ===\n";
    $stmt = $pdo->query("DESCRIBE historyloan");
    $historyColumns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $historyLoanColumns = [];
    foreach ($historyColumns as $column) {
        $historyLoanColumns[] = $column['Field'];
        echo $column['Field'] . " - " . $column['Type'] . "\n";
    }
    
    // Step 4: Drop all loan-related triggers
    echo "\n=== Dropping Triggers ===\n";
    $dropQueries = [
        "DROP TRIGGER IF EXISTS backupedLoan",
        "DROP TRIGGER IF EXISTS backup_loan_trigger",
        "DROP TRIGGER IF EXISTS loan_backup_trigger",
        "DROP TRIGGER IF EXISTS loan_delete_trigger"
    ];
    
    foreach ($dropQueries as $query) {
        try {
            $pdo->exec($query);
            echo "Executed: $query\n";
        } catch (Exception $e) {
            echo "Warning: $query failed: " . $e->getMessage() . "\n";
        }
    }
    
    // Step 5: Create new trigger without image field
    echo "\n=== Creating New Trigger ===\n";
    
    // Build field lists dynamically
    $commonFields = ['loanId', 'amount', 'rate', 'startDate', 'endDate', 'note', 'updatedAmount', 'type', 'userId', 'custId'];
    $triggerFields = [];
    $triggerValues = [];
    
    foreach ($commonFields as $field) {
        if (in_array($field, $loanColumns) && in_array($field, $historyLoanColumns)) {
            $triggerFields[] = $field;
            $triggerValues[] = "OLD.$field";
        }
    }
    
    // Add optional fields
    if (in_array('paymentMode', $loanColumns) && in_array('paymentMode', $historyLoanColumns)) {
        $triggerFields[] = 'paymentMode';
        $triggerValues[] = 'COALESCE(OLD.paymentMode, "cash")';
    }
    
    if (in_array('custName', $historyLoanColumns)) {
        $triggerFields[] = 'custName';
        $triggerValues[] = 'customer_name';
    }
    
    $fieldsStr = implode(', ', $triggerFields);
    $valuesStr = implode(', ', $triggerValues);
    
    echo "Fields: $fieldsStr\n";
    echo "Values: $valuesStr\n";
    
    $createTriggerQuery = "
    CREATE TRIGGER `backupedLoan` 
    BEFORE DELETE ON `loan` 
    FOR EACH ROW 
    BEGIN
        DECLARE customer_name VARCHAR(100) DEFAULT 'Unknown Customer';
        
        -- Get customer name
        SELECT custName INTO customer_name 
        FROM customer 
        WHERE custId = OLD.custId 
        LIMIT 1;
        
        -- Insert into historyloan
        INSERT INTO historyloan ($fieldsStr)
        VALUES ($valuesStr);
        
        -- Archive loan documents
        INSERT INTO history_loan_documents (loanId, documentPath, archivedDate)
        SELECT OLD.loanId, documentPath, NOW()
        FROM loan_documents 
        WHERE loanId = OLD.loanId;
        
        -- Delete loan documents
        DELETE FROM loan_documents WHERE loanId = OLD.loanId;
    END
    ";
    
    try {
        $pdo->exec($createTriggerQuery);
        echo "✅ New trigger created successfully!\n";
    } catch (Exception $e) {
        echo "❌ Failed to create trigger: " . $e->getMessage() . "\n";
    }
    
    // Step 6: Verify trigger
    echo "\n=== Verifying New Trigger ===\n";
    $stmt = $pdo->query("SHOW TRIGGERS LIKE 'loan'");
    $triggers = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($triggers as $trigger) {
        echo "✅ Trigger: " . $trigger['Trigger'] . " - Event: " . $trigger['Event'] . " - Timing: " . $trigger['Timing'] . "\n";
    }
    
    echo "\n✅ Database trigger fix completed!\n";
    
} catch(PDOException $e) {
    echo "❌ Connection failed: " . $e->getMessage() . "\n";
}
?>
