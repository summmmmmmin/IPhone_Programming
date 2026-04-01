<?php
$name=$_POST["name"];
$description=$_POST["description"];
$userid=$_POST["userid"];




$db_addr = "localhost";
$db_id = "root";
$db_pwd = "00000000";
$db_name = "team_senior";
$conn = new mysqli($db_addr, $db_id, $db_pwd, $db_name);

if($conn){

} else {
    echo "fail<br>";
}


$sql = "INSERT INTO teams (name, description, owner_id) 
        VALUES('$name','$description','$userid');"; 


$createteam_result = 0;



if(mysqli_query($conn, $sql)){
    $createteam_result = 1; // 성공
} else {
    $createteam_result = 0; // 실패
}


//role 0 : 팀장
//status 0 : 승인 완료
$sql = "INSERT INTO team_memberships (user_id, role, status, teams_id, favorite) 
        VALUES('$userid', 0, 0, LAST_INSERT_ID(), 1);"; 


$createteam1_result = 0;



if(mysqli_query($conn, $sql)){
    $createteam1_result = 1; // 성공
} else {
    $createteam1_result = 0; // 실패
}




echo $createteam_result;
?>