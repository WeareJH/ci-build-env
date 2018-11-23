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
    jpeg \
    jpeg-dev \
    g++ \
    icu \
    icu-dev \
    libmcrypt-dev \
    libxslt-dev \
    libstdc++ \
    libgcc \
    ruby \
    ruby-bundler

RUN docker-php-ext-install \
    gd \
    intl \
    mbstring \
    mcrypt \
    pdo_mysql \
    xsl \
    zip \
    soap \
    bcmath \
    mysqli \
    opcache \
    pcntl

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer 
ENV PATH=/root/.composer/vendor/bin:$PATH

RUN composer global require wearejh/m2-deploy-recipe:dev-master

RUN apk add nodejs yarn
RUN yarn global add m2-builder@1

RUN mkdir -p /root/build
WORKDIR /root/build

RUN mkdir $HOME/.ssh
COPY ./config/php.ini /usr/local/etc/php/conf.d/php-custom.ini
