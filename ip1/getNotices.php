<?php
// getNotices.php 
header('Content-Type: application/json; charset=utf-8');

// 데이터베이스 연결 정보 
$db_addr = "localhost";
$db_id = "root";
$db_pwd = "00000000"; 
$db_name = "team_senior"; 

$teamID = isset($_POST['teams_id']) ? intval($_POST['teams_id']) : 0;

if ($teamID == 0) {
    // 팀 ID가 없으면 빈 목록을 반환
    echo '{"notices": []}';
    exit;
}

$conn = new mysqli($db_addr, $db_id, $db_pwd, $db_name);

if ($conn->connect_error) {
    // DB 연결 오류 시 명시적 오류 반환
    echo '{"error": "DB_CONNECT_FAILED: ' . $conn->connect_error . '"}';
    exit;
}
$conn->set_charset("utf8");

$sql = "SELECT 
            n.id, 
            n.team_id, 
            n.author_id, 
            n.title, 
            n.body,             
            n.is_pinned, 
            n.created_at,       
            u.name AS author_name  
        FROM notices n
        JOIN users u ON n.author_id = u.id
        WHERE n.team_id = ? 
        ORDER BY n.is_pinned DESC, n.created_at DESC"; // 고정 게시글을 먼저 표시

$stmt = $conn->prepare($sql);
if ($stmt === false) {
    echo '{"error": "SQL_PREPARE_FAILED: ' . $conn->error . '"}';
    $conn->close();
    exit;
}

$stmt->bind_param("i", $teamID);
$stmt->execute();
$result = $stmt->get_result();

$notices = array();
while ($row = $result->fetch_assoc()) {
    $notices[] = array(
        "id" => (int)$row['id'],
        "team_id" => (int)$row['team_id'],
        "author_id" => (int)$row['author_id'],
        "title" => $row['title'],
        "body" => $row['body'],
        "is_pinned" => (int)$row['is_pinned'],
        "created_at" => $row['created_at'],
        "author_name" => $row['author_name']
    );
}


echo json_encode(array("notices" => $notices)); 

$stmt->close();
$conn->close();
?>