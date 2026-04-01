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

$sql = "SELECT teams.name
        FROM team_memberships
        LEFT JOIN users ON users.id = team_memberships.user_id
        LEFT JOIN teams ON teams.id = team_memberships.teams_id
        WHERE team_memberships.user_id = '$id' AND team_memberships.favorite=1
        AND team_memberships.status = 0
        ORDER BY team_memberships.created_at DESC
        LIMIT 1;";

//echo $sql

$result = mysqli_query($conn, $sql);
$teamname_result = 0;

while($row = mysqli_fetch_array($result)){

   $teamname_result = $row["name"];
}
echo $teamname_result;
?>