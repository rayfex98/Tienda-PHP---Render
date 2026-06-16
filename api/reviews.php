<?php
// api/reviews.php
// Handles reviews requests (GET, POST)

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
            // Check if filtering by productId
            if (!empty($_GET['productId'])) {
                $stmt = $pdo->prepare("SELECT * FROM reviews WHERE productId = ? ORDER BY date DESC");
                $stmt->execute([$_GET['productId']]);
            } else {
                $stmt = $pdo->query("SELECT * FROM reviews ORDER BY date DESC");
            }
            
            $reviews = [];
            while ($row = $stmt->fetch()) {
                $row['rating'] = (int)$row['rating'];
                $reviews[] = $row;
            }
            
            echo json_encode($reviews);
            break;

        case 'POST':
            $input = json_decode(file_get_contents('php://input'), true);
            
            if (!$input || empty($input['productId']) || empty($input['userName']) || !isset($input['rating'])) {
                http_response_code(400);
                echo json_encode(["error" => "Incomplete review data. ProductId, UserName and Rating are required."]);
                break;
            }
            
            $id = !empty($input['id']) ? $input['id'] : 'rev-' . round(microtime(true) * 1000);
            $productId = $input['productId'];
            $userName = $input['userName'];
            $rating = (int)$input['rating'];
            $comment = isset($input['comment']) ? $input['comment'] : '';
            $date = !empty($input['date']) ? $input['date'] : date('Y-m-d');

            // Insert new review
            $sql = "INSERT INTO reviews (id, productId, userName, rating, comment, date) 
                    VALUES (:id, :productId, :userName, :rating, :comment, :date)";
            
            $stmt = $pdo->prepare($sql);
            $stmt->execute([
                ':id' => $id,
                ':productId' => $productId,
                ':userName' => $userName,
                ':rating' => $rating,
                ':comment' => $comment,
                ':date' => $date
            ]);

            // Dynamically update product average rating
            $updateSql = "UPDATE products 
                          SET rating = (SELECT ROUND(AVG(rating), 1) FROM reviews WHERE productId = :productId) 
                          WHERE id = :productId";
            $updateStmt = $pdo->prepare($updateSql);
            $updateStmt->execute([':productId' => $productId]);

            // Construct response matching frontend fields
            $response = [
                'id' => $id,
                'productId' => $productId,
                'userName' => $userName,
                'rating' => $rating,
                'comment' => $comment,
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
