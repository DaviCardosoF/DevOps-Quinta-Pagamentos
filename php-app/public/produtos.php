<?php
// Configurações do cabeçalho para retornar JSON
header("Content-Type: application/json");

// Credenciais do banco de dados (pegas das variáveis de ambiente)
$host = getenv('DB_HOST');       // "mysql-db" (nome do container)
$dbname = getenv('DB_NAME');     // "dbteste"
$user = getenv('DB_USER');       // "appuser"
$password = getenv('DB_PASSWORD'); // "senha123"

try {
    // Conexão com o MySQL
    $conn = new PDO("mysql:host=$host;dbname=$dbname", $user, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Consulta para buscar produtos
    $query = $conn->query("SELECT * FROM produtos");
    $produtos = $query->fetchAll(PDO::FETCH_ASSOC);

    // Retorna os produtos em JSON
    echo json_encode($produtos);

} catch (PDOException $e) {
    // Em caso de erro, retorna mensagem de erro
    echo json_encode([
        "erro" => "Falha na conexão com o banco de dados",
        "detalhes" => $e->getMessage()
    ]);
}
?>