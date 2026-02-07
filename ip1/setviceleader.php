<?php
$teams_id = $_POST["teams_id"];
$user_id = $_POST["user_id"];
$role = 1;

$db_addr = "localhost";
$db_id = "root";
$db_pwd = "00000000";
$db_name = "team_senior";
$conn = new mysqli($db_addr, $db_id, $db_pwd, $db_name);

if($conn->connect_error){
    echo "DB Connection Fail";
    exit();
}

$sql = "UPDATE team_memberships 
        SET role = '$role' 
        WHERE teams_id = '$teams_id' AND user_id = '$user_id'";

if (mysqli_query($conn, $sql)) {
    if (mysqli_affected_rows($conn) > 0) {
        echo "Success";
    } else {
        echo "Error: No matching membership found or role already set.";
    }
} else {
    echo "Error updating record: " . mysqli_error($conn);
}

mysqli_close($conn);
?>