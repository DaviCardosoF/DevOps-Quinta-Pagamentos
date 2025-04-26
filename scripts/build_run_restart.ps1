Set-Location -Path $PSScriptRoot

# Remove containers antigos
docker rm -f mysql-db php-app flask-api 2>$null

# Cria rede se não existir
if (-not (docker network ls -q -f name=rede-projeto-php)) {
    docker network create rede-projeto-php
}

# Sobe MySQL
docker run -d `
    --name mysql-db `
    --network rede-projeto-php `
    -e MYSQL_ROOT_PASSWORD=senha123 `
    -e MYSQL_DATABASE=dbteste `
    -e MYSQL_USER=appuser `
    -e MYSQL_PASSWORD=senha123 `
    -p 3306:3306 `
    -v mysql_data:/var/lib/mysql `
    --restart unless-stopped `
    mysql:8.0 `
    --character-set-server=utf8mb4 `
    --collation-server=utf8mb4_unicode_ci `
    --default-authentication-plugin=mysql_native_password

Start-Sleep -Seconds 5  # Espera o MySQL iniciar

# Sobe PHP (versão corrigida)
docker build -t projeto-php ../php-app
docker run -d `
    --name php-app `
    --network rede-projeto-php `
    -p 80:80 `
    -e DB_HOST=mysql-db `
    -e DB_NAME=dbteste `
    -e DB_USER=appuser `
    -e DB_PASSWORD=senha123 `
    -v ${PWD}/../php-app/public:/var/www/html `
    projeto-php

Start-Sleep -Seconds 3  # Espera o PHP iniciar

# Sobe Flask
docker build -t flask-api ../flask-api
docker run -d `
    --name flask-api `
    --network rede-projeto-php `
    -p 5000:5000 `
    -v ${PWD}/../flask-api:/app `
    flask-api

# Reinicia nginx
Start-Sleep -Seconds 2
docker exec php-app service nginx reload

Write-Host "✅ Todos os serviços foram iniciados com sucesso!"
Write-Host "PHP API: http://localhost"
Write-Host "Flask API: http://localhost:5000"