<?php
$host = getenv('DB_HOST');
$dbname = getenv('DB_NAME');
$user = getenv('DB_USER');
$password = getenv('DB_PASSWORD');

try {
    $conn = new PDO("mysql:host=$host;dbname=$dbname", $user, $password);
    echo "Conectado ao MySQL com sucesso!";

    $stmt = $conn->query("SELECT * FROM produtos");
    $produtos = $stmt->fetchAll(PDO::FETCH_ASSOC);

} catch (PDOException $e) {
    echo "Erro: " . $e->getMessage();
}
?>