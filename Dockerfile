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
    libxslt-dev \
    libstdc++ \
    libgcc \
    libzip-dev \
    ruby \
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
    coreutils \
    gcompat

RUN docker-php-ext-configure gd --with-jpeg=/usr/include/ --with-freetype=/usr/include/ \
    && docker-php-ext-configure zip

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
    sockets \
    sodium \
    ftp

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
ENV PATH=/root/.composer/vendor/bin:$PATH

RUN composer selfupdate --{{COMPOSER_VERSION}}
RUN composer config --global github-oauth.github.com {{GITHUB_TOKEN}}

RUN composer global config minimum-stability dev

RUN composer global config repositories.m2-deploy-recipe vcs git@github.com:WeareJH/m2-deploy-recipe.git

RUN composer global require wearejh/m2-deploy-recipe:^3.0

# Install NVM and multiple versions of Node
RUN touch ~/.profile && chmod +x ~/.profile
RUN echo 'export NVM_NODEJS_ORG_MIRROR=https://unofficial-builds.nodejs.org/download/release;' >> $HOME/.profile; \
    echo 'export NVM_DIR="$HOME/.nvm";' >> $HOME/.profile; \
    echo 'nvm_get_arch() { nvm_echo "x64-musl"; }' >> $HOME/.profile;
RUN source ~/.profile; curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash;
RUN echo 'nvm_get_arch() { nvm_echo "x64-musl"; }' >> $HOME/.nvm/nvm.sh;
RUN source ~/.profile; . ~/.nvm/nvm.sh
RUN source ~/.profile && nvm install 18 && nvm install 20 && nvm install 22 && nvm alias default 20;
RUN source ~/.profile && nvm use default && npm install --global yarn
RUN echo 'source $HOME/.profile;' > $HOME/.ashrc;
ENV ENV="/root/.ashrc"
# Symlink node/npm/npx to /usr/local/bin for non-interactive shell access
RUN source ~/.profile && ln -sf $(which node) /usr/local/bin/node \
    && ln -sf $(which npm) /usr/local/bin/npm \
    && ln -sf $(which npx) /usr/local/bin/npx
# End of install NVM

RUN apk add chromium

RUN source ~/.profile && yarn global add m2-builder@4

# Install elgentos static-deploy binary
RUN ARCH=$(uname -m | sed 's/x86_64/amd64/') && \
    curl -sL -o /usr/local/bin/static-deploy \
    "https://github.com/elgentos/magento2-static-deploy/releases/latest/download/magento2-static-deploy-linux-${ARCH}" && \
    chmod +x /usr/local/bin/static-deploy || true

RUN mkdir -p /root/build
WORKDIR /root/build

RUN mkdir $HOME/.ssh
COPY ./config/php.ini /usr/local/etc/php/conf.d/php-custom.ini