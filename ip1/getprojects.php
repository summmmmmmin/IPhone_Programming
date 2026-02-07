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


$sql = "SELECT id, team_id, name, description, due_at FROM projects
        WHERE team_id=$team_id;"; 
$result = mysqli_query($conn, $sql);

$projects='{"projects":[';

$cnt=0;


while($row=mysqli_fetch_array($result)){
    $cnt=$cnt+1;

    if($cnt!=1){
        $projects=$projects.',';
    }

    $projects=$projects.'{"id":' . $row['id'] . ',"team_id":' . $row['team_id'] . ', "name":"' . $row['name'] . '", "description":"' . $row['description'] . '", "due_at":"' . $row['due_at'] . '"}';

}
$projects=$projects.']}';



echo $projects;

mysqli_close($conn);
?>
