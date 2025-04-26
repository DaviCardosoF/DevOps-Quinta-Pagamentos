# Aguarda o MySQL subir completamente
Start-Sleep -Seconds 10

# Nome do banco
$nomeBanco = "dbteste"

# Caminho temporário para o arquivo SQL
$tempSqlPath = "$PSScriptRoot\setup.sql"

# Conteúdo do script SQL
@"
-- Cria o banco se não existir
CREATE DATABASE IF NOT EXISTS $nomeBanco CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Cria o usuário se não existir
CREATE USER IF NOT EXISTS 'appuser'@'%' IDENTIFIED BY 'senha123';

-- Dá permissões ao usuário
GRANT ALL PRIVILEGES ON $nomeBanco.* TO 'appuser'@'%';
FLUSH PRIVILEGES;

-- Usa o banco
USE $nomeBanco;

-- Cria a tabela produtos se não existir
CREATE TABLE IF NOT EXISTS produtos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10, 2) NOT NULL,
    estoque INT DEFAULT 0,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Cria a tabela pagamentos se não existir
CREATE TABLE IF NOT EXISTS pagamentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_produto INT NOT NULL,
    nome_produto VARCHAR(255) NOT NULL,
    valor_pago DECIMAL(10,2) NOT NULL,
    data_pagamento TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insere produtos de exemplo
INSERT INTO produtos (nome, descricao, preco, estoque) VALUES
('Produto Exemplo 1', 'Descrição do produto 1', 99.99, 10),
('Produto Exemplo 2', 'Descrição do produto 2', 149.90, 5)
ON DUPLICATE KEY UPDATE preco = VALUES(preco);
"@ | Out-File -Encoding utf8 -FilePath $tempSqlPath

# Copia o arquivo para dentro do container
docker cp $tempSqlPath mysql-db:/setup.sql

# Executa o SQL dentro do container
Get-Content $tempSqlPath | docker exec -i mysql-db mysql -uroot -psenha123

# Limpa o arquivo temporário
Remove-Item $tempSqlPath -Force

Write-Host "Banco '$nomeBanco', usuário 'appuser' e tabelas criados com sucesso!"
