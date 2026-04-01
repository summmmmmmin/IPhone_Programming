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

// +) 차단 검사
$check_banned_sql = "SELECT id FROM team_memberships 
                WHERE user_id='$userid' AND teams_id='$teams_id' AND status = 4 LIMIT 1";
$check_banned_result = mysqli_query($conn, $check_banned_sql);

if ($check_banned_result && mysqli_num_rows($check_banned_result) > 0) {
    echo 4; 
    exit;
}

// 1) 신청 중복 검사
$check_sql = "SELECT id FROM team_memberships 
                WHERE user_id='$userid' AND teams_id='$teams_id' AND status IN(0,1) LIMIT 1";
$check_result = mysqli_query($conn, $check_sql);

if ($check_result && mysqli_num_rows($check_result) > 0) {
    // 신청 중복
    echo -1;
    exit;
}


// 2) 이미 가입 완료
$ifjoin_sql = "SELECT id FROM team_memberships 
                WHERE user_id='$userid' AND teams_id='$teams_id' AND status =0 ";
$ifjoin_result = mysqli_query($conn, $ifjoin_sql);

if ($ifjoin_result && mysqli_num_rows($ifjoin_result) > 0) {
    // 신청 중복
    echo 3;
    exit;
}

//3) 신청 성공
// role 2 : 팀원
// status 1 : 승인 대기 중
$sql = "INSERT INTO team_memberships (user_id, role, status, teams_id) 
VALUES(".$userid.", 2, 1, ".$teams_id.");"; 

$applyteam_result = 0;



if(mysqli_query($conn, $sql)){
    $applyteam_result = 1; // 성공
} else {
    $applyteam_result = 0; // 실패
}




echo $applyteam_result;
?>
