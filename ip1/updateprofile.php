<?php

$id=$_POST["id"];
$name=$_POST["name"];
$profile_img = isset($_POST["profile_img"]) ? $_POST["profile_img"] : null;

$db_addr = "localhost";
$db_id = "root";
$db_pwd = "00000000";
$db_name = "team_senior";
$conn = new mysqli($db_addr, $db_id, $db_pwd, $db_name);

if(!$conn){
    echo "fail<br>";
    exit();
}
$update_fields = "name = '$name'";

if ($profile_img !== null) {
    $update_fields .= ", profile_img = '$profile_img'";
}

if(isset($_POST["password"]) && !empty($_POST["password"])) {
    $password = $_POST["password"];
    $update_fields .= ", password = '$password'";
}

$sql = "UPDATE users SET $update_fields WHERE id = '$id'";

$update_return = 0;

if(mysqli_query($conn, $sql)) {
    $update_return = 1;
} else {
    $update_return = 0;
}

echo $update_return;

?>