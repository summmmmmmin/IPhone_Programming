<?php
$team_id=$_POST["team_id"];

$db_addr = "localhost";
$db_id = "root";
$db_pwd = "00000000";
$db_name = "team_senior";
$conn = new mysqli($db_addr, $db_id, $db_pwd, $db_name);

if($conn){

} else {
    echo "fail<br>";
}

//$sql = "SELECT users.name, users.email, team_memberships.user_id, team_memberships.id, team_memberships.role, users.profile_img
        //FROM team_memberships
       // LEFT JOIN users ON users.id = team_memberships.user_id
        //WHERE team_memberships.teams_id = '$teams_id'
       // AND team_memberships.status = 0
       // AND team_memberships.role != 0;";

$sql = "SELECT meetings.id, meetings.team_id, meetings.title, meetings.notes, users.name 
        FROM meetings
        LEFT JOIN users ON users.id = meetings.author_id
        WHERE team_id=$team_id
        ;"; 

$result = mysqli_query($conn, $sql);

$meetings='{"meetings":[';

$cnt=0;


while($row=mysqli_fetch_array($result)){
    $cnt=$cnt+1;

    if($cnt!=1){
        $meetings=$meetings.',';
    }

    $meetings=$meetings.'{"id":' . $row['id'] . ',"team_id":' . $row['team_id'] . ', "title":"' . $row['title'] . '", "notes":"' . $row['notes'] . '", "name":"' . $row['name'] . '"}';

}
$meetings=$meetings.']}';



echo $meetings;

mysqli_close($conn);
?>
