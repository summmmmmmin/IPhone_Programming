<?php
$id=$_POST["id"];

$db_addr = "localhost";
$db_id = "root";
$db_pwd = "00000000";
$db_name = "team_senior";
$conn = new mysqli($db_addr, $db_id, $db_pwd, $db_name);

if($conn){

} else {
    echo "fail<br>";
}

$update_sql = "UPDATE projects
                SET status = 2
                WHERE id = '$id'
                AND status != 1                            -- 이미 완료된(1) 프로젝트는 업데이트하지 않음
                AND due_at < NOW()                         -- due_at이 현재 시각보다 작은 경우 (즉, 마감 기한이 지난 경우)
                AND status != 2;";


$conn->query($update_sql);
// status 0 : 진행 중
// status 1 : 완료
// status 2 : 만료
$sql = "SELECT status from projects
        where id='$id';"; 



$result = mysqli_query($conn, $sql);
$project_result = 7;


while($row = mysqli_fetch_array($result)){

   $project_result = $row["status"];
}

echo $project_result;
?>