<?php
// =====================================
// update_task_status.php
// Task의 status, due_on을 업데이트합니다.
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
$status = $_POST['status'] ?? null; 
$due_on = $_POST['due_on'] ?? null; 

if (!$task_id || $status === null) {
    echo json_encode(["success" => false, "message" => "Missing required fields"]);
    $conn->close();
    exit();
}

// SQL 구성
$sql = "UPDATE Tasks SET status = ?";
$types = "i";
$params = [$status];

if ($due_on !== null && $due_on !== "") {
    $sql .= ", due_on = ?"; 
    $types .= "s";
    $params[] = $due_on;
}

$sql .= " WHERE id = ?";
$types .= "i";
$params[] = $task_id;

$stmt = $conn->prepare($sql);
if (!$stmt) {
    echo json_encode(["success" => false, "message" => "Prepare failed: " . $conn->error]);
    $conn->close();
    exit();
}

// PHP 8 이상이면 spread 연산자로 bind_param 가능
$stmt->bind_param($types, ...$params);

// 실행
if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Task updated successfully"]);
} else {
    echo json_encode(["success" => false, "message" => "Task update failed: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
