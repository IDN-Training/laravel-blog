# Use a slim PHP-FPM image as the base
FROM php:8.4-fpm-alpine

# Install system dependencies and required PHP extensions
RUN apk add --no-cache \
    git \
    curl \
    mysql-client \
    bash \
    nginx \
    autoconf \
    g++ \
    make

# Install Node.js and npm for frontend asset compilation (Vite)
RUN apk add --no-cache nodejs npm

# Install essential PHP extensions for Laravel
RUN docker-php-ext-install \
    pdo_mysql \
    bcmath \
    curl \
    mbstring \
    gd \
    zip \
    xml

# Set the working directory inside the container
WORKDIR /var/www/html

# Copy composer files to leverage Docker's caching
COPY composer.json composer.lock ./

# Install Composer dependencies without development packages
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader

# Copy package files for frontend dependencies
COPY package.json package-lock.json ./

# Install frontend dependencies and build assets with Vite
RUN npm install
RUN npm run build

# Copy the entire application code into the container
COPY . .

# Set proper permissions for Laravel's storage and cache directories
RUN chown -R www-data:www-data storage bootstrap/cache
RUN chmod -R 775 storage bootstrap/cache

# Copy the Nginx configuration and a custom entrypoint script
COPY nginx.conf /etc/nginx/sites-available/default
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Expose port 80 for the Nginx web server
EXPOSE 80

# Use a custom entrypoint script to start both Nginx and PHP-FPM
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
