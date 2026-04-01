<?php
// getUsersTeamID.php

// 🚩 Swift가 팀 이름과 ID를 모두 받으려면 반드시 JSON 헤더를 추가해야 합니다.
header('Content-Type: application/json; charset=utf-8'); 

// 데이터베이스 연결 정보 (제공해주신 코드를 참고하여 설정)
$db_addr = "localhost";
$db_id = "root";
$db_pwd = "00000000";
$db_name = "team_senior";

// 1. POST 데이터 받기
$userid = isset($_POST['userid']) ? $_POST['userid'] : 0;

// 기본 응답 데이터 구조 (팀이 없거나 실패 시)
$response = [
    "teams_id" => 0,
    "teams_name" => "소속된 팀 없음" // 팀이 없을 때 기본값
];

// 사용자 ID가 유효하지 않으면 기본 응답 출력 후 종료
if ($userid == 0) {
    echo json_encode($response);
    exit;
}

// 2. 데이터베이스 연결
$conn = new mysqli($db_addr, $db_id, $db_pwd, $db_name);

if ($conn->connect_error) {
    // DB 연결 오류 시에도 JSON 형식으로 응답
    $response["teams_name"] = "DB 연결 오류";
    echo json_encode($response);
    exit;
}
$conn->set_charset("utf8");

// 3. 쿼리 실행: teams와 team_memberships를 조인하여 팀 ID와 팀 이름을 모두 조회합니다.
// T: teams 테이블, TM: team_memberships 테이블
// status=0 조건은 활성화된 팀 멤버십을 가정합니다.
$sql = "SELECT 
            T.id AS teams_id, 
            T.name AS teams_name 
        FROM teams T
        INNER JOIN team_memberships TM ON T.id = TM.teams_id
        WHERE TM.user_id = ? AND TM.status = 0 
        LIMIT 1";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $userid);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    
    // 🚩 조회된 팀 ID와 이름을 응답 배열에 저장
    $response["teams_id"] = (int)$row['teams_id'];
    $response["teams_name"] = $row['teams_name'];
    
    // DB에서 teams_id가 NULL인 경우 (논리적으로 발생해서는 안 되지만 대비)
    if ($response["teams_id"] === null) {
        $response["teams_id"] = 0;
        $response["teams_name"] = "팀 정보 오류";
    }

} else {
    // 쿼리 결과가 없을 경우 (팀에 소속되지 않은 경우) 기본 응답 유지 (teams_id=0, teams_name="소속된 팀 없음")
}

// 4. 🚩 JSON 객체를 출력합니다. (Swift의 TeamInfo 구조체와 일치)
echo json_encode($response);

$stmt->close();
$conn->close();
?>