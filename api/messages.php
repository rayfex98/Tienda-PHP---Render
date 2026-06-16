<?php
// api/messages.php
// Handles contact messages requests (GET, POST)

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once 'db.php';

$method = $_SERVER['REQUEST_METHOD'];

try {
    switch ($method) {
        case 'GET':
            // Fetch messages in descending order (newest first)
            $stmt = $pdo->query("SELECT * FROM messages ORDER BY date DESC");
            $messages = $stmt->fetchAll();
            echo json_encode($messages);
            break;

        case 'POST':
            $input = json_decode(file_get_contents('php://input'), true);
            
            if (!$input || empty($input['name']) || empty($input['email']) || empty($input['subject']) || empty($input['message'])) {
                http_response_code(400);
                echo json_encode(["error" => "Incomplete message data. Name, email, subject and message are required."]);
                break;
            }
            
            $id = !empty($input['id']) ? $input['id'] : 'msg-' . round(microtime(true) * 1000);
            $name = $input['name'];
            $email = $input['email'];
            $subject = $input['subject'];
            $message = $input['message'];
            
            // Format date to ISO/MySQL standard
            $date = !empty($input['date']) ? $input['date'] : date('Y-m-d H:i:s');

            $sql = "INSERT INTO messages (id, name, email, subject, message, date) 
                    VALUES (:id, :name, :email, :subject, :message, :date)";
            
            $stmt = $pdo->prepare($sql);
            $stmt->execute([
                ':id' => $id,
                ':name' => $name,
                ':email' => $email,
                ':subject' => $subject,
                ':message' => $message,
                ':date' => $date
            ]);

            $response = [
                'id' => $id,
                'name' => $name,
                'email' => $email,
                'subject' => $subject,
                'message' => $message,
                'date' => $date
            ];
            
            http_response_code(201); // Created
            echo json_encode($response);
            break;

        default:
            http_response_code(405);
            echo json_encode(["error" => "Method not allowed"]);
            break;
    }
} catch (\PDOException $e) {
    http_response_code(500);
    echo json_encode(["error" => "Database error occurred", "message" => $e->getMessage()]);
}
