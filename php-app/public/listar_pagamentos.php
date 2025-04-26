<?php
header("Content-Type: application/json");

$host = getenv('DB_HOST');
$dbname = getenv('DB_NAME');
$user = getenv('DB_USER');
$password = getenv('DB_PASSWORD');

try {
    $conn = new PDO("mysql:host=$host;dbname=$dbname", $user, $password);
    $stmt = $conn->query("SELECT * FROM pagamentos ORDER BY data_pagamento DESC");
    $pagamentos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode($pagamentos);

} catch (PDOException $e) {
    echo json_encode([
        "erro" => "Erro ao buscar pagamentos",
        "detalhes" => $e->getMessage()
    ]);
}
?>
