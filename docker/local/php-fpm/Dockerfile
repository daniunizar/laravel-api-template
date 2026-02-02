# Use the official MYSQL base image
ARG PHP_BASE_IMAGE
FROM php:${PHP_BASE_IMAGE:-8.3-fpm-alpine3.20}

# Install packages
RUN apk add --no-cache \
    curl \
    git \
    build-base \
    zlib-dev \
    oniguruma-dev \
    autoconf \
    bash \
    supervisor

## Configurating Xdebug
ARG PHP_DEBUG
RUN if [[ ${PHP_DEBUG} = true ]]; then \
    apk add --update linux-headers && \
    pecl install xdebug && \
    docker-php-ext-enable xdebug; \
   fi;

COPY ./docker/local/php-fpm/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
COPY ./docker/local/php-fpm/uploads.ini /usr/local/etc/php/conf.d/uploads.ini

RUN apk add --no-cache libpq-dev zlib-dev g++ git icu-dev zip libzip-dev libpng-dev libjpeg-turbo-dev libwebp-dev freetype-dev \
    && pecl install apcu \
    && docker-php-ext-configure zip \
    && docker-php-ext-configure gd --with-jpeg --with-webp --with-freetype \
    && docker-php-ext-install zip intl opcache pdo pdo_mysql gd \
    && docker-php-ext-enable apcu

WORKDIR /var/www

## Installing Composer
ARG PHP_COMPOSER_VERSION
RUN wget -q "https://getcomposer.org/download/$PHP_COMPOSER_VERSION/composer.phar" -O /usr/local/bin/composer && \
    chmod 0755 /usr/local/bin/composer

## Configuring Supervisor
RUN mkdir /etc/supervisor.d/
COPY ./docker/local/php-fpm/supervisor-php.ini /etc/supervisor.d/

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]