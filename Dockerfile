FROM ubuntu:18.04

# Replace shell with bash so we can source files
RUN rm /bin/sh \
    && ln -s /bin/bash /bin/sh

# Set debconf to run non-interactively
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install base dependencies
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
    curl \
    zip \
    unzip \
    wget \
    git-core \
    python-pip \
    jq

# Install aws cli
RUN pip install awscli

# Install PHP
RUN echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu bionic main" > /etc/apt/sources.list.d/ppa_ondrej_php.list \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E5267A6C \
    && apt-get update \
    && apt-get install -y \
        php7.3 \
        php7.3-curl \
        php7.3-common \
        php7.3-json \
        php7.3-mbstring \
        php7.3-xml

# Install Composer
ENV COMPOSER_HOME /usr/local/bin/.composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer global require hirak/prestissimo:@stable \
    && composer clear-cache

# Add composer bin to path
ENV PATH="${COMPOSER_HOME}/vendor/bin:${PATH}"

# Install Node and NPM
ARG NVM_DIR=/usr/local/nvm
ARG NVM_VERSION=0.34.0
RUN mkdir -p $NVM_DIR \
    && wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v$NVM_VERSION/install.sh | bash \
    && source $NVM_DIR/nvm.sh \
    && nvm install --lts \
    && nvm use --lts \
    && n=$(which node) \
    && n=${n%/bin/node} \
    && chmod -R 755 $n/bin/* \
    && cp -r $n/{bin,lib,share} /usr/local \
    && nvm unload \
    && rm -rf $NVM_DIR

# Cleanup
RUN apt-get -y autoremove \
    && apt-get clean \
    && rm -rf ~/* /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && history -c
