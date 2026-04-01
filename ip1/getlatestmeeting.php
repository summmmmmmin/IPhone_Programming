<?php
$team_id=$_POST["team_id"];

$db_addr = "localhost";
$db_id = "root";
$db_pwd = "00000000";
$db_name = "team_senior";
$conn = new mysqli($db_addr, $db_id, $db_pwd, $db_name);

if($conn){

} else {
    echo "fail<br>";
}


$sql = "SELECT id, team_id, title, notes from meetings
where team_id='$team_id' 
ORDER BY created_at DESC
LIMIT 1;";

$result = mysqli_query($conn, $sql);

$projects='{"latestmeetings":[';

$cnt=0;


while($row=mysqli_fetch_array($result)){
    $projects=$projects.'{"id":' . $row['id'] . ', "team_id":' . $row['team_id'] . ',"title":"' . $row['title'] . '", "notes":"' . $row['notes'] . '"}';
}
$projects=$projects.']}';



echo $projects;

mysqli_close($conn);
?>