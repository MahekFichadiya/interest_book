<?php
include("connection.php");

$loanId = $_GET['loanId'] ?? null;

if (!$loanId) {
    http_response_code(400);
    echo json_encode(["error" => "loanId missing"]);
    exit;
}

try {
    // Use prepared statement for security
    $query = "SELECT depositeId, depositeAmount, depositeDate, depositeNote, loanId
              FROM deposite WHERE loanId = ? ORDER BY depositeDate DESC";
    $stmt = mysqli_prepare($con, $query);
    mysqli_stmt_bind_param($stmt, "i", $loanId);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);

    $response = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $response[] = $row;
    }

    http_response_code(200);
    echo json_encode($response);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["error" => "Database error: " . $e->getMessage()]);
}
?>
