<?php
// =====================================
// create_task.php
// 새 Task를 DB에 삽입합니다.
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

// 연결 오류 체크
if ($conn->connect_error) {
    echo json_encode(["success" => false, "message" => "Connection failed: " . $conn->connect_error]);
    exit();
}

// POST 데이터 받기
$project_id = $_POST['project_id'] ?? null;
$title = $_POST['title'] ?? null;
$description = $_POST['description'] ?? ""; // 💡 수정: description이 없을 경우 빈 문자열로 초기화
$due_on = $_POST['due_on'] ?? null;           

if (!$project_id || !$title || !$due_on) {
    echo json_encode(["success" => false, "message" => "Missing required fields"]);
    exit();
}

// 필수 값 세팅
$status = 0; // 초기 상태 TODO
$start_on = date("Y-m-d H:i:s"); // start_on 필수이므로 현재 시간으로 넣음

// INSERT 준비
$stmt = $conn->prepare("INSERT INTO Tasks (project_id, title, description, status, due_on, start_on) VALUES (?, ?, ?, ?, ?, ?)");

if (!$stmt) {
    echo json_encode(["success" => false, "message" => "Prepare failed: " . $conn->error]);
    $conn->close();
    exit();
}

$stmt->bind_param("ississ", $project_id, $title, $description, $status, $due_on, $start_on);

// 실행
if ($stmt->execute()) {
    echo json_encode([
        "success" => true,
        "message" => "Task created successfully",
        "task_id" => $conn->insert_id
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Task creation failed: " . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>