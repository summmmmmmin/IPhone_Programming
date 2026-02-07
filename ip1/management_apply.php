<?php
$user_id=$_POST["user_id"];
$teams_id=$_POST["teams_id"];
//$name=$_POST["name"];

$db_addr = "localhost";
$db_id = "root";
$db_pwd = "00000000";
$db_name = "team_senior";
$conn = new mysqli($db_addr, $db_id, $db_pwd, $db_name);

if($conn){

} else {
    echo "fail<br>";
}


$sql = "SELECT team_memberships.teams_id, users.name, team_memberships.id, team_memberships.user_id, users.email, users.profile_img
        FROM team_memberships
        LEFT JOIN users ON users.id = team_memberships.user_id
        LEFT JOIN teams ON teams.id = team_memberships.teams_id
        WHERE team_memberships.teams_id = '$teams_id'
        AND team_memberships.status = 1;";


$result = mysqli_query($conn, $sql);

$managements='{"managements":[';

$cnt=0;


while($row=mysqli_fetch_array($result)){
    $cnt=$cnt+1;

    if($cnt!=1){
        $managements=$managements.',';
    }

    $profile_img_value = $row['profile_img'];
    $profile_img_safe = ($profile_img_value === null) ? "" : $profile_img_value;

    $managements=$managements.'{"id":' . $row['id'] . ',"user_id":' . $row['user_id'] . ',"team_id":' . $row['teams_id'] . ',"name":"' . $row['name'] . '","email":"' . $row['email'] . '", "profile_img":"' . $profile_img_safe . '"}';

}
$managements=$managements.']}';


echo $managements;

mysqli_close($conn);
?>
