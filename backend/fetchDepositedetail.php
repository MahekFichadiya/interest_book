<?php
include("connection.php");

$loanId = $_GET['loanId'] ?? null;

if (!$loanId) {
    http_response_code(400);
    echo json_encode(["error" => "loanId missing"]);
    exit;
}

try {
    // Check if depositeField column exists
    $checkColumnQuery = "SHOW COLUMNS FROM deposite LIKE 'depositeField'";
    $checkResult = mysqli_query($con, $checkColumnQuery);
    $hasDepositeField = mysqli_num_rows($checkResult) > 0;

    // Use prepared statement for security with appropriate columns
    if ($hasDepositeField) {
        // Include depositeField column if it exists (note: using loanid to match database schema)
        $query = "SELECT depositeId, depositeAmount, depositeDate, depositeNote, loanid as loanId, depositeField
                  FROM deposite WHERE loanid = ? ORDER BY depositeDate DESC";
    } else {
        // Fallback query without depositeField column
        $query = "SELECT depositeId, depositeAmount, depositeDate, depositeNote, loanid as loanId
                  FROM deposite WHERE loanid = ? ORDER BY depositeDate DESC";
    }

    $stmt = mysqli_prepare($con, $query);
    mysqli_stmt_bind_param($stmt, "i", $loanId);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);

    $response = [];
    while ($row = mysqli_fetch_assoc($result)) {
        // Ensure depositeField exists in response for backward compatibility
        if (!isset($row['depositeField'])) {
            $row['depositeField'] = 'cash'; // Default value for old records
        }
        $response[] = $row;
    }

    http_response_code(200);
    echo json_encode($response);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["error" => "Database error: " . $e->getMessage()]);
}
?>
