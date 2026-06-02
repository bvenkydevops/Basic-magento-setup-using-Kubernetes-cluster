FROM php:8.3-fpm

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    curl \
    libzip-dev \
    libicu-dev \
    libxml2-dev \
    libxslt-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev

RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg
RUN echo "memory_limit=4G" > /usr/local/etc/php/conf.d/memory-limit.ini
RUN docker-php-ext-install \
    bcmath \
    ftp \
    gd \
    intl \
    mysqli \
    pdo_mysql \
    soap \
    sockets \
    xsl \
    zip

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
