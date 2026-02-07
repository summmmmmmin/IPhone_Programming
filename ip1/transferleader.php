<?php
$new_leader_id=$_POST["new_leader_id"];
$teams_id=$_POST["teams_id"];

$db_addr = "localhost";
$db_id = "root";
$db_pwd = "00000000";
$db_name = "team_senior";
$conn = new mysqli($db_addr, $db_id, $db_pwd, $db_name);

if($conn->connect_error){
    echo "DB Connection Fail";
    exit();
}

// 1. 기존 팀장 role=0 -> 2
$sql_old_leader = "UPDATE team_memberships 
                   SET role = 2 
                   WHERE teams_id = '$teams_id' AND role = 0";

if (!mysqli_query($conn, $sql_old_leader)) {
    echo "Error changing old leader role: " . mysqli_error($conn);
    mysqli_close($conn);
    exit();
}


// 2. 선택한 팀원 role=2 -> 0
$sql_new_leader = "UPDATE team_memberships SET role = 0 WHERE id = '$new_leader_id'";

if (mysqli_query($conn, $sql_new_leader)) {
    echo "Success";
} else {
    echo "Error updating new leader role: " . mysqli_error($conn);
}

mysqli_close($conn);
?>