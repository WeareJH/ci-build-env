FROM ubuntu:17.04
MAINTAINER Michael Woodward <michael@wearejh.com>

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8

RUN apt-get update && \
    apt-get install -y \
    software-properties-common \
    language-pack-en-base \
    curl

RUN add-apt-repository ppa:ondrej/php && apt-get update
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -

RUN apt-get install -y \
    openssh-server \
    php7.1 \
    nodejs \
    git \
    nmap

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN npm install -g yarn
