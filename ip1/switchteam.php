<?php
$userid=$_POST["userid"];
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

//$sql = "select * from teams where teams_id = '$teams_id';"; 

// role 2 : 팀원
// status 1 : 승인 대기 중


$sql = "UPDATE team_memberships
        SET favorite = 0
        WHERE user_id = $userid;";
mysqli_query($conn, $sql);

$sql = "UPDATE team_memberships
        SET favorite = 1
        WHERE user_id = $userid AND teams_id =$teams_id;";
mysqli_query($conn, $sql);

$sql = "SELECT id, name, description FROM teams
        where id=$teams_id ";

//echo $sql;
$result = mysqli_query($conn, $sql);

$teams='{"switchteam":[';

$cnt=0;


while($row=mysqli_fetch_array($result)){
    $teams=$teams.'{"id":' . $row['id'] . ', "name":"' . $row['name'] . '", "description":"' . $row['description'] . '"}';
}
$teams=$teams.']}';



echo $teams;

mysqli_close($conn);
?>