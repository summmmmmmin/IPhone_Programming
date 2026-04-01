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

$sql = //"SELECT teams.name AS teamname, users.name AS name, users.email AS email, teams.id AS id
        "SELECT teams.name AS teamname, users.name AS name, users.email AS email, users.profile_img AS profile_img, teams.id AS id
        FROM team_memberships
        LEFT JOIN users ON users.id = team_memberships.user_id
        LEFT JOIN teams ON teams.id = team_memberships.teams_id
        WHERE team_memberships.user_id = '$id'
        ORDER BY team_memberships.created_at DESC
        LIMIT 1;";



/*if($row = mysqli_fetch_array($result)){
    $profile_data['teamid'] = $row['id'];
    $profile_data['teamname'] = $row['teamname'];
    $profile_data['name'] = $row['name'];
    $profile_data['email'] = $row['email'];
}*/
$result = mysqli_query($conn, $sql);

$profile_data='';

$cnt=0;


while($row=mysqli_fetch_array($result)){
    $cnt=$cnt+1;

    if($cnt!=1){
        $profile_data=$profile_data.',';
    }

    //$profile_data=$profile_data.'{"teamid":' . $row['id'] . ', "teamname":"' . $row['teamname'] . '", "name":"' . $row['name'] . '", "email":"' . $row['email'] . '"}';
    $profile_data=$profile_data.'{"teamid":' . $row['id'] . ', "teamname":"' . $row['teamname'] . '", "name":"' . $row['name'] . '", "email":"' . $row['email'] . '", "profile_img":"' . $row['profile_img'] . '"}';

}
$profile_data=$profile_data.'';



echo $profile_data;

mysqli_close($conn);
?>