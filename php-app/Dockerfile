FROM php:8.2-fpm

# Instala dependências + extensão MySQL
RUN apt-get update && apt-get install -y \
    nginx \
    curl \
    unzip \
    && docker-php-ext-install pdo pdo_mysql \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html
COPY . .
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf

# Expõe a porta 80 e inicia serviços
EXPOSE 80
CMD ["sh", "-c", "service nginx start && php-fpm"]