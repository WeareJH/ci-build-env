FROM php:{{PHP_VERSION}}-cli-alpine
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
    icu-data-full \
    libmcrypt-dev \
    libxslt-dev \
    libstdc++ \
    libgcc \
    libzip-dev \
    ruby \
    ruby-json \
    ruby-bundler \
    libsodium-dev \
    oniguruma-dev \
    procps \
    perl-utils \
    zlib \
    python3 \
    make \
    bash \
    linux-headers \
    coreutils

RUN [ $(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") -lt 74 ] \
    && docker-php-ext-configure gd --with-jpeg-dir=/usr/include/ --with-freetype-dir=/usr/include/ \
    && docker-php-ext-configure zip --with-libzip=/usr/include/ \
    ; true

RUN [ $(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") -ge 74 ] \
    && docker-php-ext-configure gd --with-jpeg=/usr/include/ --with-freetype=/usr/include/ \
    && docker-php-ext-configure zip \
    ; true

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
    && docker-php-ext-install mcrypt \
    ; true

RUN [ $(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") -ge 72 ] \
    && docker-php-ext-install sodium \
    ; true

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
ENV PATH=/root/.composer/vendor/bin:$PATH

RUN composer selfupdate --{{COMPOSER_VERSION}}
RUN composer config --global github-oauth.github.com {{GITHUB_TOKEN}}

RUN composer global config minimum-stability dev

RUN composer global config repositories.m2-deploy-recipe vcs git@github.com:WeareJH/m2-deploy-recipe.git
RUN if [ $(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") -lt 81 ] ; then \
    composer global require wearejh/m2-deploy-recipe:^1.0; \
  else \
    composer global require wearejh/m2-deploy-recipe:^2.0; \
  fi

RUN composer global config repositories.ci-tool vcs git@github.com:WeareJH/ci-tool.git
RUN [ $(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") -ge 74 ] \
    && [ $(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") -lt 81 ] \
    && composer global require wearejh/ci-tool:dev-master \
    ; true

# Install NVM and multiple versions of Node
RUN touch ~/.profile && chmod +x ~/.profile
RUN echo 'export NVM_NODEJS_ORG_MIRROR=https://unofficial-builds.nodejs.org/download/release;' >> $HOME/.profile; \
    echo 'export NVM_DIR="$HOME/.nvm";' >> $HOME/.profile; \
    echo 'nvm_get_arch() { nvm_echo "x64-musl"; }' >> $HOME/.profile;
RUN source ~/.profile; curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash;
RUN echo 'nvm_get_arch() { nvm_echo "x64-musl"; }' >> $HOME/.nvm/nvm.sh;
RUN source ~/.profile; . ~/.nvm/nvm.sh
RUN source ~/.profile && nvm install 16 && nvm install 18 && nvm install 20 && nvm alias default 16;
RUN source ~/.profile && nvm use default && npm install --global yarn
RUN echo 'source $HOME/.profile;' > $HOME/.ashrc;
ENV ENV="/root/.ashrc"
# End of install NVM

RUN apk add chromium

RUN source ~/.profile && yarn global add m2-builder@4

RUN mkdir -p /root/build
WORKDIR /root/build

RUN mkdir $HOME/.ssh
COPY ./config/php.ini /usr/local/etc/php/conf.d/php-custom.ini
