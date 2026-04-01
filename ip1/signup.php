<?php
$name=$_POST["name"];
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




// 1) 이메일 중복 검사
$check_sql = "SELECT id FROM users WHERE email='$email' LIMIT 1";
$check_result = mysqli_query($conn, $check_sql);

if ($check_result && mysqli_num_rows($check_result) > 0) {
    // 이메일 중복
    echo -1;
    exit;
}

$sql = "INSERT INTO users (name, email, password) 
        VALUES('$name','$email', '$password')
        ON DUPLICATE KEY UPDATE email = email"; 


$signup_result = 0; 



$sql = "INSERT INTO users (name, email, password)
        VALUES('$name','$email', '$password')";

if (mysqli_query($conn, $sql)) {
    $signup_result = 1;  // 성공
} else {
    $signup_result = 0;  // 실패
}

echo $signup_result;
?>