<?php
$management_id=$_POST["id"];
$status=$_POST["status"];

$db_addr = "localhost";
$db_id = "root";
$db_pwd = "00000000";
$db_name = "team_senior";
$conn = new mysqli($db_addr, $db_id, $db_pwd, $db_name);

if($conn->connect_error){
    echo "DB Connection Fail";
    exit();
}

// status 업데이트
// status: 0=승인, 1=신청 중, 2=거절, 4=차단
$sql = "UPDATE team_memberships SET status = '$status' WHERE id = '$management_id'";

if (mysqli_query($conn, $sql)) {
    echo "Success: Status updated to " . $status;
} else {
    echo "Error updating record: " . mysqli_error($conn);
}

mysqli_close($conn);
?>