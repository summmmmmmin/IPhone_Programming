<?php

$id=$_POST["id"];

$db_addr = "localhost";
$db_id = "root";
$db_pwd = "00000000";
$db_name = "team_senior";
$conn = new mysqli($db_addr, $db_id, $db_pwd, $db_name);

if(!$conn){
    echo "fail<br>";
    exit();
}

$sql = "select name, email, password, profile_img from users where id = '$id';"; 

$result = mysqli_query($conn, $sql);
$profile_data = array();

if($row = mysqli_fetch_array($result)){
    $profile_data['name'] = $row['name'];
    $profile_data['email'] = $row['email'];
    $profile_data['password'] = $row['password'];
    $profile_data['profile_img'] = $row['profile_img'];
}

echo json_encode($profile_data);

?>
