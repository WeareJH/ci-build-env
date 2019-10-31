FROM php:{{VERSION}}-cli-alpine
MAINTAINER JH <hello@wearejh.com>

RUN apk --update add \
    curl \
    git \
    knock \
    openssh \
    mysql-client \
    patch \
    rsync \
    libpng \
    libpng-dev \
    freetype-dev \
    jpeg \
    jpeg-dev \
    g++ \
    icu \
    icu-dev \
    libmcrypt-dev \
    libxslt-dev \
    libstdc++ \
    libgcc \
    libzip-dev \
    ruby \
    ruby-json \
    ruby-bundler \
    libsodium-dev \
    nodejs \
    npm \
    yarn

RUN docker-php-ext-configure gd --with-jpeg-dir=/usr/include/ --with-freetype-dir=/usr/include/
RUN docker-php-ext-configure zip --with-libzip=/usr/include/

RUN docker-php-ext-install \
    gd \
    intl \
    mbstring \
    pdo_mysql \
    xsl \
    zip \
    soap \
    bcmath \
    mysqli \
    opcache \
    pcntl \
    sockets

RUN [ $(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") -lt 72 ] \
    && docker-php-ext-install \
        mcrypt \
    ; true

RUN [ $(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") -ge 72 ] \
    && docker-php-ext-install \
        sodium \
    ; true

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
ENV PATH=/root/.composer/vendor/bin:$PATH

RUN composer global require wearejh/m2-deploy-recipe:dev-master

RUN yarn global add m2-builder@4

RUN mkdir -p /root/build
WORKDIR /root/build

RUN mkdir $HOME/.ssh
COPY ./config/php.ini /usr/local/etc/php/conf.d/php-custom.ini
