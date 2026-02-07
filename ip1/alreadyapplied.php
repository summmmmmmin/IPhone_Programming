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

//1) 이미 신청 완료
$alreadyapplied_sql = "SELECT id FROM team_memberships 
                WHERE user_id='$userid' AND teams_id='$teams_id' AND status = 1 LIMIT 1";
$alreadyapplied_result = mysqli_query($conn, $alreadyapplied_sql);

if ($alreadyapplied_result && mysqli_num_rows($alreadyapplied_result) > 0) {
    // 신청 중복
    echo 1;
    exit;
}

// 2) 이미 가입 완료
$ifjoin_sql = "SELECT id FROM team_memberships 
                WHERE user_id='$userid' AND teams_id='$teams_id' AND status =0 LIMIT 1 ";
$ifjoin_result = mysqli_query($conn, $ifjoin_sql);

if ($ifjoin_result && mysqli_num_rows($ifjoin_result) > 0) {
    // 신청 중복
    echo 3;
    exit;
}





//if(mysqli_query($conn, $sql)){
 //   $alreadyapplied_result = 1; // 성공
//} else {
  //  $alreadyapplied_result = 0; // 실패
//}




//echo $alreadyapplied_result;
?>
