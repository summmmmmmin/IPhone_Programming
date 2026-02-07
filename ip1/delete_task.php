<?php
// =====================================
// delete_task.php
// Task를 DB에서 삭제합니다.
// =====================================

// DB 연결 정보
$servername = "localhost";
$username = "root";       
$password = "00000000";   
$dbname = "team_senior";  

$conn = new mysqli($servername, $username, $password, $dbname);
$conn->set_charset("utf8mb4");

// JSON 헤더
header('Content-Type: application/json; charset=utf-8');

// 연결 체크
if ($conn->connect_error) {
    echo json_encode(["success" => false, "message" => "Connection failed: " . $conn->connect_error]);
    exit();
}

// POST 데이터 받기
$task_id = $_POST['task_id'] ?? null;

if (!$task_id) {
    echo json_encode(["success" => false, "message" => "Missing required field: task_id"]);
    $conn->close();
    exit();
}

// SQL 구성 및 실행 (Prepared Statement 사용)
$sql = "DELETE FROM Tasks WHERE id = ?";
$stmt = $conn->prepare($sql);

if (!$stmt) {
    echo json_encode(["success" => false, "message" => "Prepare failed: " . $conn->error]);
    $conn->close();
    exit();
}

// 파라미터 바인딩
$stmt->bind_param("i", $task_id); // "i"는 정수(integer) 타입

// 실행
if ($stmt->execute()) {
    // 삭제 성공
    echo json_encode(["success" => true, "message" => "Task deleted successfully"]);
} else {
    // 삭제 실패
    echo json_encode(["success" => false, "message" => "Task deletion failed: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>