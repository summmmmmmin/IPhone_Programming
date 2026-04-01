<?php
require __DIR__.'/db.php';

header('Content-Type: application/json; charset=utf-8');

try {
    $raw = file_get_contents('php://input');
    $in  = json_decode($raw, true, 512, JSON_THROW_ON_ERROR);

    $name = trim($in['name'] ?? '');
    $desc = $in['description'] ?? '';
    $due  = $in['due_at'] ?? null;

    //  team_id null 처리
    $team = (array_key_exists('team_id', $in) && $in['team_id'] !== null)
        ? (int)$in['team_id']
        : null;

    if ($name === '') {
        throw new RuntimeException('name required');
    }

    // 팀 과제일 때만 팀 존재 체크
    if ($team !== null) {
        $chk = $mysqli->prepare("SELECT 1 FROM teams WHERE id=?");
        $chk->bind_param("i", $team);
        $chk->execute();

        if ($chk->get_result()->num_rows === 0) {
            echo json_encode([
                'success' => false,
                'message' => 'invalid team_id'
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
    }

    $stmt = $mysqli->prepare("
        INSERT INTO projects (team_id, name, description, due_at, created_at, status, achieved)
        VALUES (?, ?, ?, ?, NOW(), 0, 0)
    ");

    $stmt->bind_param("isss", $team, $name, $desc, $due);
    $stmt->execute();

    echo json_encode([
        'success' => true,
        'id' => $stmt->insert_id
    ], JSON_UNESCAPED_UNICODE);

} catch (Throwable $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}