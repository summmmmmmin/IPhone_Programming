<?php
// deleteComment.php

// 데이터베이스 연결 정보 (동일)
$db_addr = "localhost";
$db_id = "root";
$db_pwd = "00000000";
$db_name = "team_senior";

// 1. POST 데이터 받기 (동일)
$comment_id = isset($_POST['id']) ? intval($_POST['id']) : 0;

if ($comment_id == 0) {
    echo "0";
    exit;
}

// 2. 데이터베이스 연결 (동일)
$conn = new mysqli($db_addr, $db_id, $db_pwd, $db_name);

if ($conn->connect_error) {
    echo "0";
    exit;
}
$conn->set_charset("utf8");

// 3. 쿼리 실행: 댓글 삭제

$sql = "DELETE FROM notice_comments WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $comment_id);

if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        echo "1";
    } else {
        echo "0";
    }
} else {
    echo "0";
}

$stmt->close();
$conn->close();
?>