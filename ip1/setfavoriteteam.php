<?php

$id=$_POST["id"];
$teamid=$_POST["teamid"];

$db_addr = "localhost";
$db_id = "root";
$db_pwd = "00000000";
$db_name = "team_senior";
$conn = new mysqli($db_addr, $db_id, $db_pwd, $db_name);

if($conn){

} else {
    echo "fail<br>";
}

//$sql = "SELECT teams.id
       // FROM team_memberships
       // LEFT JOIN users ON users.id = team_memberships.user_id
        //LEFT JOIN teams ON teams.id = team_memberships.teams_id
        //WHERE team_memberships.user_id = '$id' AND team_memberships.favorite=1
       // AND team_memberships.status = 0
       // ORDER BY team_memberships.created_at DESC
        //LIMIT 1;";

$sql=  "UPDATE team_memberships
        SET favorite = 1
        WHERE user_id = '$id'
        AND teams_id = '$teamid'
        AND status = 0
        AND (NOT EXISTS (select 1 from
            (
				SELECT id
				FROM team_memberships 
				WHERE user_id = '$id'
				AND status = 0
				AND favorite = 1
				LIMIT 1
			) as team2
		)) 
  ;
";
//괄호 안 서브쿼리가 아무것도 반환하지 않을 때 where절은 true. 
// Not Exists(select 1)은 하나라도 찾으면 검색 중단한다는 뜻

$result = mysqli_query($conn, $sql);
$setfavoriteteam_result = 0;



if(mysqli_query($conn, $sql)){
    $setfavoriteteam_result = 1; // 성공
} else {
    $setfavoriteteam_result = 0; // 실패
}



echo $setfavoriteteam_result;


?>