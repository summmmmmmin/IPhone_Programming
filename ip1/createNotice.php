<?php
// createNotice.php

// 데이터베이스 연결 정보
$db_addr = "localhost";
$db_id = "root";
$db_pwd = "00000000";
$db_name = "team_senior";

// 1. POST 데이터 받기
$teamID = isset($_POST['teams_id']) ? intval($_POST['teams_id']) : 0;
$title = isset($_POST['title']) ? $_POST['title'] : '';
$content = isset($_POST['content']) ? $_POST['content'] : '';
$authorID = isset($_POST['author_id']) ? intval($_POST['author_id']) : 0; 

$isPinned = isset($_POST['is_pinned']) ? intval($_POST['is_pinned']) : 0; 


if ($teamID == 0 || $authorID == 0 || empty($title) || empty($content)) {
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


$sql = "INSERT INTO notices (team_id, author_id, title, body, is_pinned) VALUES (?, ?, ?, ?, ?)";
$stmt = $conn->prepare($sql);


$stmt->bind_param("iissi", $teamID, $authorID, $title, $content, $isPinned); 

if ($stmt->execute()) {
    echo "1"; // 성공
} else {
    echo "0"; // 실패
}

$stmt->close();
$conn->close();
?>