<?php
// getComments.php (최종 수정: SQL 쿼리 내 주석 제거)

header('Content-Type: application/json; charset=utf-8');

// 데이터베이스 연결 정보 (동일)
$db_addr = "localhost";
$db_id = "root";
$db_pwd = "00000000";
$db_name = "team_senior";

$noticeID = isset($_POST['notice_id']) ? intval($_POST['notice_id']) : 0;

if ($noticeID == 0) {
    echo '[]';
    exit;
}

$conn = new mysqli($db_addr, $db_id, $db_pwd, $db_name);

if ($conn->connect_error) {
    echo '[]'; 
    exit;
}
$conn->set_charset("utf8");


$sql = "SELECT 
            c.id, 
            c.notice_id, 
            c.author_id, 
            c.body, 
            u.name AS nickname 
        FROM notice_comments c
        JOIN users u ON c.author_id = u.id  
        WHERE c.notice_id = ?
        ORDER BY c.created_at ASC"; 

$stmt = $conn->prepare($sql);

if ($stmt === false) {
    // 쿼리 준비 실패 시 빈 배열 반환
    // print("SQL Prepare Error: " . $conn->error); // 디버깅 시 사용
    echo '[]'; 
    $conn->close();
    exit;
}

$stmt->bind_param("i", $noticeID);
$stmt->execute();
$result = $stmt->get_result();

$comments = array();

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $comments[] = array(
            "id" => (int)$row['id'],
            "notice_id" => (int)$row['notice_id'], 
            "user_id" => (int)$row['author_id'], 
            "content" => $row['body'],          
            "nickname" => $row['nickname']
        );
    }
}

// 최종 JSON 출력
echo json_encode($comments);

$stmt->close();
$conn->close();
?>