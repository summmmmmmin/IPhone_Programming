<?php
$email=$_POST["email"];
$password=$_POST["password"];



$db_addr = "localhost";
$db_id = "root";
$db_pwd = "00000000";
$db_name = "team_senior";
$conn = new mysqli($db_addr, $db_id, $db_pwd, $db_name);

if($conn){

} else {
    echo "fail<br>";
}

$sql = "select * from users where email = '$email' and password = '$password';"; 

//echo $sql

$result = mysqli_query($conn, $sql);
$login_result = 0;

while($row = mysqli_fetch_array($result)){

   $login_result = $row["id"];
}
echo $login_result;
?>