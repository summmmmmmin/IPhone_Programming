<?php
// updateNotice.php (새로 추가)

// 데이터베이스 연결 정보
$db_addr = "localhost";
$db_id = "root";
$db_pwd = "00000000";
$db_name = "team_senior";

// 1. POST 데이터 받기
$notice_id = isset($_POST['id']) ? intval($_POST['id']) : 0;
$title = isset($_POST['title']) ? $_POST['title'] : '';
$content = isset($_POST['content']) ? $_POST['content'] : '';
$is_pinned = isset($_POST['is_pinned']) ? intval($_POST['is_pinned']) : 0; 

// 필수 필드 유효성 검사
if ($notice_id == 0 || empty($title) || empty($content)) {
    echo "0"; // 실패 (데이터 부족)
    exit;
}

// 2. 데이터베이스 연결
$conn = new mysqli($db_addr, $db_id, $db_pwd, $db_name);

if ($conn->connect_error) {
    echo "0"; // 실패 (DB 연결 오류)
    exit;
}
$conn->set_charset("utf8");

// 3. 쿼리 실행: 게시글 업데이트 (제목, 내용, 고정 여부 수정)
$sql = "UPDATE notices SET title = ?, body = ?, is_pinned = ? WHERE id = ?";
$stmt = $conn->prepare($sql);

// "ssii": s=string(title), s=string(content), i=integer(is_pinned), i=integer(id)
$stmt->bind_param("ssii", $title, $content, $is_pinned, $notice_id);

if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        echo "1"; // 성공 (업데이트됨)
    } else {
        // 업데이트 성공이지만 내용이 변경되지 않았을 수도 있음 (성공으로 처리)
        echo "1"; 
    }
} else {
    echo "0"; // 실패
}

$stmt->close();
$conn->close();
?>