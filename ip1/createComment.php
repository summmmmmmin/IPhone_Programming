<?php

// createComment.php



// 데이터베이스 연결 정보 (동일)

$db_addr = "localhost";
$db_id = "root";
$db_pwd = "00000000";
$db_name = "team_senior";



// 1. POST 데이터 받기 (변수명은 Swift와 통일, 사용 시 칼럼명으로 매핑)

$notice_id = isset($_POST['notice_id']) ? intval($_POST['notice_id']) : 0;
$user_id = isset($_POST['user_id']) ? intval($_POST['user_id']) : 0; // Swift에서 보낸 user_id를 받습니다.
$content = isset($_POST['content']) ? $_POST['content'] : ''; // Swift에서 보낸 content를 받습니다.



if ($notice_id == 0 || $user_id == 0 || empty($content)) {
echo "0"; // 실패 (데이터 부족)
exit;
}



// 2. 데이터베이스 연결 (동일)

$conn = new mysqli($db_addr, $db_id, $db_pwd, $db_name);
if ($conn->connect_error) {
echo "0"; // 실패 (DB 연결 오류)
exit;
}

$conn->set_charset("utf8");





$sql = "INSERT INTO notice_comments (notice_id, author_id, body) VALUES (?, ?, ?)";

$stmt = $conn->prepare($sql);





$stmt->bind_param("iis", $notice_id, $user_id, $content);



if ($stmt->execute()) {

echo "1"; // 성공

} else {

echo "0"; // 쿼리 실행 실패

}



$stmt->close();
$conn->close();

?>