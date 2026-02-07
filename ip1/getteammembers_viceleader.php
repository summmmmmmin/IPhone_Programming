<?php
$teams_id = $_POST["teams_id"];
$my_user_id = $_POST["my_user_id"];

$db_addr = "localhost";
$db_id = "root";
$db_pwd = "00000000";
$db_name = "team_senior";
$conn = new mysqli($db_addr, $db_id, $db_pwd, $db_name);

if ($conn->connect_error) {
    echo "DB Connection Fail";
    exit();
}

// status=0 (승인 완료), role=2 (팀원)
$sql = "SELECT users.name, users.email, team_memberships.user_id, team_memberships.id, team_memberships.role, users.profile_img
        FROM team_memberships
        LEFT JOIN users ON users.id = team_memberships.user_id
        WHERE team_memberships.teams_id = '$teams_id'
        AND team_memberships.status = 0
        AND team_memberships.user_id != '$my_user_id';";

$result = mysqli_query($conn, $sql);

$members = '{"managements":[';
$cnt = 0;

while($row = mysqli_fetch_array($result)){
    $cnt += 1;

    if($cnt != 1){
        $members .= ',';
    }

    $profile_img_value = $row['profile_img'] ?? '';
    
    $members .= '{"id":' . $row['id'] . 
                ',"user_id":' . $row['user_id'] . 
                ',"name":"' . $row['name'] . 
                '","email":"' . $row['email'] . 
                '","role":"' . $row['role'] . 
                '", "profile_img":"' . $profile_img_value. '"}';
    
}
$members .= ']}';

echo $members;

mysqli_close($conn);
?>
