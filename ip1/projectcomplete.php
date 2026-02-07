<?php
$id=$_POST["id"];

$db_addr = "localhost";
$db_id = "root";
$db_pwd = "00000000";
$db_name = "team_senior";
$conn = new mysqli($db_addr, $db_id, $db_pwd, $db_name);

if($conn){

} else {
    echo "fail<br>";
}

$update_sql = "UPDATE projects
                SET status = 1
                WHERE id = '$id'
                AND status != 1 ;";


$conn->query($update_sql);
// status 0 : 진행 중
// status 1 : 완료
// status 2 : 만료
$sql = "SELECT status from projects
        where id='$id';"; 



$result = mysqli_query($conn, $sql);
$projectcomplete_result = 7;


while($row = mysqli_fetch_array($result)){

   $projectcomplete_result = $row["status"];
}

echo $projectcomplete_result;
?>