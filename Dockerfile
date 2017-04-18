FROM ubuntu:17.04
MAINTAINER Michael Woodward <michael@wearejh.com>

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8

RUN apt-get update && \
    apt-get install -y \
    software-properties-common \
    language-pack-en-base \
    curl \
    git \
    knockd \
    openssh-server

RUN add-apt-repository ppa:ondrej/php && apt-get update
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -

RUN apt-get install -y \
    nodejs \
    php7.0 \
    php7.0-curl \
    php7.0-intl \
    php7.0-gd \
    php7.0-mbstring \
    php7.0-xml \
    php7.0-mcrypt \
    php7.0-bcmath \
    php7.0-zip

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN npm install -g yarn

RUN mkdir -p /root/build
WORKDIR /root/build
