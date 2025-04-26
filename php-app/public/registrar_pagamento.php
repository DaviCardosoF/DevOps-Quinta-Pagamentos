<?php
header("Content-Type: application/json");

// Conexão com o banco
$host = getenv('DB_HOST');
$dbname = getenv('DB_NAME');
$user = getenv('DB_USER');
$password = getenv('DB_PASSWORD');

try {
    $conn = new PDO("mysql:host=$host;dbname=$dbname", $user, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Lê os dados JSON enviados
    $dados = json_decode(file_get_contents("php://input"), true);
    $id_produto = $dados["id_produto"] ?? null;
    $nome_produto = $dados["nome_produto"] ?? null;
    $valor_pago = $dados["valor"] ?? null;

    if (!$id_produto || !$nome_produto || !$valor_pago) {
        echo json_encode(["erro" => "Dados incompletos"]);
        exit;
    }

    // Insere o pagamento no banco
    $stmt = $conn->prepare("INSERT INTO pagamentos (id_produto, nome_produto, valor_pago) VALUES (?, ?, ?)");
    $stmt->execute([$id_produto, $nome_produto, $valor_pago]);

    echo json_encode(["mensagem" => "Pagamento registrado com sucesso."]);

} catch (PDOException $e) {
    echo json_encode([
        "erro" => "Erro ao registrar pagamento",
        "detalhes" => $e->getMessage()
    ]);
}
?>
