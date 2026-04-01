<?php
$userid=$_POST["id"];
$name=$_POST["name"];
$description=$_POST["description"];

$db_addr = "localhost";
$db_id = "root";
$db_pwd = "00000000";
$db_name = "team_senior";
$conn = new mysqli($db_addr, $db_id, $db_pwd, $db_name);

if($conn){

} else {
    echo "fail<br>";
}


$sql = "SELECT teams.id, teams.name, teams.description from teams
left join team_memberships on teams.id=team_memberships.teams_id
where team_memberships.user_id='$userid' AND team_memberships.status=0;";

$result = mysqli_query($conn, $sql);

$teams='{"myteams":[';

$cnt=0;


while($row=mysqli_fetch_array($result)){
    $cnt=$cnt+1;

    if($cnt!=1){
        $teams=$teams.',';
    }

    $teams=$teams.'{"id":' . $row['id'] . ', "name":"' . $row['name'] . '", "description":"' . $row['description'] . '"}';

}
$teams=$teams.']}';



echo $teams;

mysqli_close($conn);
?>