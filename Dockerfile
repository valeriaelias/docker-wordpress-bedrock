FROM php:7.3.6-fpm-alpine3.9
RUN docker-php-ext-install mysqli
WORKDIR /app
COPY . /app

# Install dependencies
RUN curl -sL https://getcomposer.org/installer | php -- --install-dir /usr/bin --filename composer


# RUN Manually via docker desktop - php container
# composer create-project roots/bedrock