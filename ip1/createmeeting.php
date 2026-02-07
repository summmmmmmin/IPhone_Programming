<?php
$title=$_POST["title"];
$notes=$_POST["notes"];
$team_id=$_POST["team_id"];
$author_id=$_POST["author_id"];



$db_addr = "localhost";
$db_id = "root";
$db_pwd = "00000000";
$db_name = "team_senior";
$conn = new mysqli($db_addr, $db_id, $db_pwd, $db_name);

if($conn){

} else {
    echo "fail<br>";
}


$sql = "INSERT INTO meetings (title, notes, team_id, author_id)
        VALUES('$title','$notes','$team_id','$author_id');"; 


$createmeeting_result = 0;



if(mysqli_query($conn, $sql)){
    $createmeeting_result = 1; // 성공
} else {
    $createmeeting_result = 0; // 실패
}






echo $createmeeting_result;
?>
