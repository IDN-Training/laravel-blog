FROM ubuntu:24.04 AS base

ENV DEBIAN_FRONTEND noninteractive

# Install dependencies
RUN apt update
RUN apt install -y software-properties-common
RUN add-apt-repository -y ppa:ondrej/php
RUN apt update
RUN apt install -y php8.4\
    php8.4-cli\
    php8.4-common\
    php8.4-fpm\
    php8.4-mysql\
    php8.4-zip\
    php8.4-gd\
    php8.4-mbstring\
    php8.4-curl\
    php8.4-xml\
    php8.4-bcmath\
    php8.4-pdo

# Install php-fpm
RUN apt install -y php8.4-fpm php8.4-cli

# Install composer
RUN apt install -y curl
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install nodejs
RUN apt install -y ca-certificates gnupg
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
ENV NODE_MAJOR 20
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN apt update
RUN apt install -y nodejs

# Install nginx
RUN apt install -y nginx
RUN echo "\
    server {\n\
        listen 80;\n\
        listen [::]:80;\n\
        root /var/www/html/public;\n\
        add_header X-Frame-Options \"SAMEORIGIN\";\n\
        add_header X-Content-Type-Options \"nosniff\";\n\
        index index.php;\n\
        charset utf-8;\n\
        location / {\n\
            try_files \$uri \$uri/ /index.php?\$query_string;\n\
        }\n\
        location = /favicon.ico { access_log off; log_not_found off; }\n\
        location = /robots.txt  { access_log off; log_not_found off; }\n\
        error_page 404 /index.php;\n\
        location ~ \.php$ {\n\
            fastcgi_pass unix:/run/php/php8.4-fpm.sock;\n\
            fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;\n\
            include fastcgi_params;\n\
        }\n\
        location ~ /\.(?!well-known).* {\n\
            deny all;\n\
        }\n\
    }\n" > /etc/nginx/sites-available/default

RUN echo "\
    #!/bin/sh\n\
    echo \"Starting services...\"\n\
    service php8.4-fpm start\n\
    nginx -g \"daemon off;\" &\n\
    echo \"Ready.\"\n\
    tail -s 1 /var/log/nginx/*.log -f\n\
    " > /start.sh

COPY . /var/www/html
WORKDIR /var/www/html

RUN chown -R www-data:www-data /var/www/html

RUN composer install
RUN npm install
RUN npm run build

EXPOSE 80

CMD ["sh", "/start.sh"]