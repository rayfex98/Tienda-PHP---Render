# Dockerfile for deploying the PHP API to Render
FROM php:8.2-apache

# Install PDO MySQL extension required for database connection
RUN docker-php-ext-install pdo pdo_mysql

# Enable Apache mod_rewrite module (useful for routing/CORS)
RUN a2enmod rewrite

# Copy our PHP API files to Apache's document root
COPY api/ /var/www/html/api/

# Set correct permissions for Apache
RUN chown -R www-data:www-data /var/www/html

# Expose default HTTP port 80 (Render binds to this automatically)
EXPOSE 80
