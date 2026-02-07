<?php
$userid=$_POST["id"];
$teams_id=$_POST["teams_id"];

$db_addr = "localhost";
$db_id = "root";
$db_pwd = "00000000";
$db_name = "team_senior";
$conn = new mysqli($db_addr, $db_id, $db_pwd, $db_name);

if($conn){

} else {
    echo "fail<br>";
}

// role 0 : 팀장
// role 1 : 부팀장
// role 2 : 팀원
// status 0 : 승인
$sql = "SELECT role from team_memberships 
        left join teams on team_memberships.teams_id=teams.id
        where team_memberships.user_id='$userid' AND team_memberships.status=0;"; 



$result = mysqli_query($conn, $sql);
$leader_result = 7;


while($row = mysqli_fetch_array($result)){

   $leader_result = $row["role"];
}

echo $leader_result;
?>