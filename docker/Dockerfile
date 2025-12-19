FROM ghcr.io/roadrunner-server/roadrunner:2025.1.5 AS roadrunner
FROM composer/composer:latest-bin AS composer
FROM php:8.4-cli

COPY --from=roadrunner /usr/bin/rr /usr/local/bin/rr

COPY --from=composer /composer /usr/local/bin/composer

RUN apt-get update -yqq && apt-get install -yqq \
    git \
    libzip-dev \
    zip \
    libgmp-dev re2c libmhash-dev libmcrypt-dev file libcurl4-gnutls-dev \
    curl \
    libonig-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    librabbitmq-dev \
    libxslt-dev supervisor

RUN pecl install igbinary \
    && docker-php-ext-enable igbinary

RUN docker-php-ext-install zip \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install sockets \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install pdo

# Install the phpredis extension using pecl
RUN pecl install redis \
    && docker-php-ext-enable redis

# Install PGSQL
RUN apt-get install -yqq libpq-dev \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo_pgsql pgsql

# Install MySQL
RUN docker-php-ext-install pdo_mysql

# Install gd
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

RUN echo 'memory_limit = 1024M' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini
RUN printf '[PHP]\ndate.timezone = "Europe/Moscow"\n' > /usr/local/etc/php/conf.d/tzone.ini

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

COPY supervisord.conf /etc/supervisor/supervisord.conf

WORKDIR /app/