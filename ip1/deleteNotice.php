<?php

header('Content-Type: text/plain; charset=utf-8');

// 데이터베이스 연결 정보
$db_addr = "localhost";
$db_id = "root";
$db_pwd = "00000000"; 
$db_name = "team_senior";

// 1. POST 데이터 받기: 삭제할 게시글의 ID
$notice_id = isset($_POST['id']) ? intval($_POST['id']) : 0;

if ($notice_id == 0) {
    echo "ERROR: ID_MISSING";
    exit;
}

// 2. 데이터베이스 연결
$conn = new mysqli($db_addr, $db_id, $db_pwd, $db_name);

if ($conn->connect_error) {
    echo "ERROR: DB_CONNECT_FAILED: " . $conn->connect_error; 
    exit;
}
$conn->set_charset("utf8");


// 3. 해당 게시글의 댓글 먼저 삭제

$sql_delete_comments = "DELETE FROM notice_comments WHERE notice_id = ?";
$stmt_comments = $conn->prepare($sql_delete_comments);

if ($stmt_comments === false) {
    echo "ERROR: COMMENT_SQL_PREPARE_FAILED: " . $conn->error;
    $conn->close();
    exit;
}

$stmt_comments->bind_param("i", $notice_id);

if (!$stmt_comments->execute()) {
    // 댓글 삭제 실패 시
    echo "ERROR: COMMENT_SQL_EXECUTE_FAILED: " . $stmt_comments->error;
    $stmt_comments->close();
    $conn->close();
    exit;
}

$stmt_comments->close();

$sql_delete_notice = "DELETE FROM notices WHERE id = ?"; 
$stmt_notice = $conn->prepare($sql_delete_notice);

if ($stmt_notice === false) {
    echo "ERROR: NOTICE_SQL_PREPARE_FAILED: " . $conn->error;
    $conn->close();
    exit;
}

$stmt_notice->bind_param("i", $notice_id);

if ($stmt_notice->execute()) {
    if ($stmt_notice->affected_rows > 0) {
        echo "1"; // 게시글 삭제 최종 성공
    } else {
        echo "ERROR: NOTICE_NOT_FOUND_OR_ALREADY_DELETED"; 
    }
} else {
    echo "ERROR: NOTICE_SQL_EXECUTE_FAILED: " . $stmt_notice->error;
}

$stmt_notice->close();
$conn->close();
?>