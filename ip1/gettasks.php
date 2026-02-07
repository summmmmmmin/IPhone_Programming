<?php
// =====================================
// gettasks.php
// project_id에 해당하는 Tasks를 조회합니다.
// =====================================

// DB 연결 정보
$servername = "localhost";
$username = "root";       
$password = "00000000";   
$dbname = "team_senior";  

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["success" => false, "error" => "Connection failed: " . $conn->connect_error]));
}

$conn->set_charset("utf8mb4");

header('Content-Type: application/json; charset=utf-8');

$project_id = $_POST['project_id'] ?? null;

// 💡 수정: user_id 체크 구문을 제거하고 project_id만 체크합니다.
if (!$project_id) { 
    echo json_encode(["success" => false, "message" => "Project ID is required"]);
    $conn->close();
    exit();
}

// 💡 쿼리 수정: project_id만 만족하는 Task만 조회합니다. (user_id 조건 제거)
$stmt = $conn->prepare("SELECT id, project_id, title, description, status, due_on FROM Tasks WHERE project_id = ? ORDER BY due_on ASC");
$stmt->bind_param("i", $project_id); 
$stmt->execute();
$result = $stmt->get_result();

$tasks = [];
while ($row = $result->fetch_assoc()) {
    $tasks[] = $row;
}

$stmt->close();
$conn->close();

echo json_encode(["tasks" => $tasks]);
?>