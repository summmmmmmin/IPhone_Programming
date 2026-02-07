<?php
$id=$_POST["id"];
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


$sql = "SELECT id, name, description FROM teams";
$result = mysqli_query($conn, $sql);

$teams='{"teams":[';

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