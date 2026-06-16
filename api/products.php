<?php
// api/products.php
// Handles CRUD requests for products

// Enable CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once 'db.php';

$method = $_SERVER['REQUEST_METHOD'];

try {
    switch ($method) {
        case 'GET':
            // Fetch all products
            $stmt = $pdo->query("SELECT * FROM products ORDER BY name ASC");
            $products = [];
            
            while ($row = $stmt->fetch()) {
                // Formatting fields to match frontend types
                $row['price'] = (float)$row['price'];
                $row['stock'] = (int)$row['stock'];
                $row['rating'] = (float)$row['rating'];
                $row['featured'] = (bool)$row['featured'];
                
                // specs is stored as JSON array string, decode it back to array
                $row['specs'] = $row['specs'] ? json_decode($row['specs'], true) : [];
                
                $products[] = $row;
            }
            
            echo json_encode($products);
            break;

        case 'POST':
            // Create a new product
            $input = json_decode(file_get_contents('php://input'), true);
            
            if (!$input || empty($input['name']) || empty($input['category'])) {
                http_response_code(400);
                echo json_encode(["error" => "Incomplete product data. Name and category are required."]);
                break;
            }
            
            // Assign default parameters if empty
            $id = !empty($input['id']) ? $input['id'] : 'prod-' . round(microtime(true) * 1000);
            $name = $input['name'];
            $description = isset($input['description']) ? $input['description'] : '';
            $price = isset($input['price']) ? (float)$input['price'] : 0.0;
            $category = $input['category'];
            $image = isset($input['image']) ? $input['image'] : 'https://images.unsplash.com/photo-1531297484001-80022131f5a1?w=600&auto=format&fit=crop&q=80';
            $stock = isset($input['stock']) ? (int)$input['stock'] : 0;
            $rating = isset($input['rating']) ? (float)$input['rating'] : 5.0;
            $featured = isset($input['featured']) ? ($input['featured'] ? 1 : 0) : 0;
            
            // specs is a frontend array, serialize to JSON string for DB
            $specs = isset($input['specs']) ? json_encode($input['specs'], JSON_UNESCAPED_UNICODE) : '[]';

            $sql = "INSERT INTO products (id, name, description, price, category, image, stock, rating, specs, featured) 
                    VALUES (:id, :name, :description, :price, :category, :image, :stock, :rating, :specs, :featured)";
            
            $stmt = $pdo->prepare($sql);
            $stmt->execute([
                ':id' => $id,
                ':name' => $name,
                ':description' => $description,
                ':price' => $price,
                ':category' => $category,
                ':image' => $image,
                ':stock' => $stock,
                ':rating' => $rating,
                ':specs' => $specs,
                ':featured' => $featured
            ]);
            
            // Return created product matching frontend structure
            $input['id'] = $id;
            $input['price'] = (float)$price;
            $input['stock'] = (int)$stock;
            $input['rating'] = (float)$rating;
            $input['featured'] = (bool)$featured;
            $input['specs'] = isset($input['specs']) ? $input['specs'] : [];
            
            http_response_code(211); // Created
            echo json_encode($input);
            break;

        case 'PUT':
            // Update an existing product
            $input = json_decode(file_get_contents('php://input'), true);
            
            if (!$input || empty($input['id']) || empty($input['name'])) {
                http_response_code(400);
                echo json_encode(["error" => "Incomplete product data. Product ID and Name are required."]);
                break;
            }
            
            $id = $input['id'];
            $name = $input['name'];
            $description = isset($input['description']) ? $input['description'] : '';
            $price = isset($input['price']) ? (float)$input['price'] : 0.0;
            $category = $input['category'];
            $image = isset($input['image']) ? $input['image'] : '';
            $stock = isset($input['stock']) ? (int)$input['stock'] : 0;
            $featured = isset($input['featured']) ? ($input['featured'] ? 1 : 0) : 0;
            
            // specs serialization
            $specs = isset($input['specs']) ? json_encode($input['specs'], JSON_UNESCAPED_UNICODE) : '[]';

            $sql = "UPDATE products 
                    SET name = :name, description = :description, price = :price, category = :category, 
                        image = :image, stock = :stock, specs = :specs, featured = :featured 
                    WHERE id = :id";
            
            $stmt = $pdo->prepare($sql);
            $stmt->execute([
                ':id' => $id,
                ':name' => $name,
                ':description' => $description,
                ':price' => $price,
                ':category' => $category,
                ':image' => $image,
                ':stock' => $stock,
                ':specs' => $specs,
                ':featured' => $featured
            ]);
            
            // Fetch updated version to send back complete entity
            $stmtFetch = $pdo->prepare("SELECT * FROM products WHERE id = ?");
            $stmtFetch->execute([$id]);
            $updated = $stmtFetch->fetch();
            
            if ($updated) {
                $updated['price'] = (float)$updated['price'];
                $updated['stock'] = (int)$updated['stock'];
                $updated['rating'] = (float)$updated['rating'];
                $updated['featured'] = (bool)$updated['featured'];
                $updated['specs'] = $updated['specs'] ? json_decode($updated['specs'], true) : [];
                echo json_encode($updated);
            } else {
                http_response_code(404);
                echo json_encode(["error" => "Product not found after updating."]);
            }
            break;

        case 'DELETE':
            // Delete a product
            if (empty($_GET['id'])) {
                http_response_code(400);
                echo json_encode(["error" => "Product ID parameter is required."]);
                break;
            }
            
            $id = $_GET['id'];
            
            $stmt = $pdo->prepare("DELETE FROM products WHERE id = ?");
            $stmt->execute([$id]);
            
            if ($stmt->rowCount() > 0) {
                echo json_encode(["success" => true, "message" => "Product deleted successfully.", "id" => $id]);
            } else {
                http_response_code(404);
                echo json_encode(["error" => "Product not found or already deleted."]);
            }
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
