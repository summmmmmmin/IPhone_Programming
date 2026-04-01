<?php
$teams_id = $_POST["teams_id"];
$user_id = $_POST["user_id"];
$status = $_POST["status"];

$db_addr = "localhost";
$db_id = "root";
$db_pwd = "00000000";
$db_name = "team_senior";
$conn = new mysqli($db_addr, $db_id, $db_pwd, $db_name);

if($conn->connect_error){
    echo "DB Connection Fail";
    exit();
}

$sql_status_update = "UPDATE team_memberships 
                      SET status = '$status' 
                      WHERE teams_id = '$teams_id' AND user_id = '$user_id'";

if (mysqli_query($conn, $sql_status_update)) {
    
    if (mysqli_affected_rows($conn) > 0 || $status == 3) {
        
        if ($status == 3) {
            
            $sql_favorite_update = "UPDATE team_memberships
                                    SET favorite = 0 
                                    WHERE teams_id = '$teams_id' AND user_id = '$user_id'";
            
            if (mysqli_query($conn, $sql_favorite_update)) {
            } else {

            }
        }
        
        echo "Success";
        
    } else {
        echo "Error: No membership status change needed or membership not found.";
    }
} else {
    echo "Error updating record: " . mysqli_error($conn);
}

mysqli_close($conn);
?>
