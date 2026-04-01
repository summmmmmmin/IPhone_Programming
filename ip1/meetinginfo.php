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

$sql = "SELECT meetings.id, meetings.title, meetings.notes, users.name
        FROM meetings
        LEFT JOIN users ON users.id = meetings.author_id
        WHERE meetings.id = $id;";


$result = mysqli_query($conn, $sql);
$meeting_result = 0;


$result = mysqli_query($conn, $sql);

$meetings='{"meetings":[';



while($row=mysqli_fetch_array($result)){

    $meetings=$meetings.'{"id":' . $row['id'] . ', "title":"' . $row['title'] . '", "notes":"' . $row['notes'] . '", "name":"' . $row['name'] . '"}';

}
$meetings=$meetings.']}';

echo $meetings;


?>