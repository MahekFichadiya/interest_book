<?php
// Test script to verify date calculation logic

echo "=== Testing Date Calculation Logic ===\n\n";

function testMonthCalculation($startDate, $description) {
    echo "Testing: $description\n";
    echo "Start Date: $startDate\n";
    
    $startDateTime = new DateTime($startDate);
    $currentDateTime = new DateTime();
    
    echo "Current Date: " . $currentDateTime->format('Y-m-d H:i:s') . "\n";
    
    // Current logic (problematic)
    $interval = $startDateTime->diff($currentDateTime);
    $monthsElapsed = ($interval->y * 12) + $interval->m;
    
    // If current day is before start day, subtract one month
    if ($currentDateTime->format('d') < $startDateTime->format('d')) {
        $monthsElapsed--;
    }
    
    // Ensure months elapsed is not negative
    $monthsElapsed = max(0, $monthsElapsed);
    
    echo "Months Elapsed (Current Logic): $monthsElapsed\n";
    
    // Better logic using TIMESTAMPDIFF equivalent
    $startTimestamp = $startDateTime->getTimestamp();
    $currentTimestamp = $currentDateTime->getTimestamp();
    
    // Calculate months more accurately
    $yearDiff = $currentDateTime->format('Y') - $startDateTime->format('Y');
    $monthDiff = $currentDateTime->format('m') - $startDateTime->format('m');
    $dayDiff = $currentDateTime->format('d') - $startDateTime->format('d');
    
    $totalMonths = ($yearDiff * 12) + $monthDiff;
    
    // If we haven't reached the same day of the month, subtract 1
    if ($dayDiff < 0) {
        $totalMonths--;
    }
    
    $totalMonths = max(0, $totalMonths);
    
    echo "Months Elapsed (Better Logic): $totalMonths\n";
    
    // Test with example calculation
    $monthlyInterest = 300; // Example: 300 Rs per month
    $totalInterest = $totalMonths * $monthlyInterest;
    
    echo "Monthly Interest: $monthlyInterest Rs\n";
    echo "Total Interest: $totalInterest Rs\n";
    echo "---\n\n";
    
    return $totalMonths;
}

// Test cases
echo "Current Date: " . date('Y-m-d H:i:s') . "\n\n";

// Test 1: Loan started today (should be 0 months)
testMonthCalculation(date('Y-m-d H:i:s'), "Loan started today");

// Test 2: Loan started 1 month ago (should be 1 month)
$oneMonthAgo = date('Y-m-d H:i:s', strtotime('-1 month'));
testMonthCalculation($oneMonthAgo, "Loan started 1 month ago");

// Test 3: Your example - June 4th to July 4th (should be 1 month)
testMonthCalculation('2024-06-04 10:00:00', "June 4th to current date");

// Test 4: May 4th to current date (should be 2 months)
testMonthCalculation('2024-05-04 10:00:00', "May 4th to current date");

// Test 5: January 1st to current date
testMonthCalculation('2024-01-01 10:00:00', "January 1st to current date");

echo "=== Test Complete ===\n";
?>
