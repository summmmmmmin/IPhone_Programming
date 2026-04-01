<?php
$name=$_POST["name"];
$description=$_POST["description"];
$team_id=$_POST["team_id"];
$due_at=$_POST["due_at"];



$db_addr = "localhost";
$db_id = "root";
$db_pwd = "00000000";
$db_name = "team_senior";
$conn = new mysqli($db_addr, $db_id, $db_pwd, $db_name);

if($conn){

} else {
    echo "fail<br>";
}


$sql = "INSERT INTO projects (name, description, team_id, due_at)
        VALUES('$name','$description','$team_id','$due_at');"; 


$createproject_result = 0;



if(mysqli_query($conn, $sql)){
    $createproject_result = 1; // 성공
} else {
    $createproject_result = 0; // 실패
}






echo $createproject_result;
?>
