FROM ubuntu:20.04

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
    python3-pip \
    jq

# Install awscli
RUN pip3 install awscli

# Install PHP
RUN apt-get update \
    && apt-get install -y \
        php7.4 \
        php7.4-curl \
        php7.4-common \
        php7.4-json \
        php7.4-mbstring \
        php7.4-xml

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
RUN mkdir -p $NVM_DIR \
    && NVM_VERSION=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | jq -r .tag_name) \
    && wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | bash \
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
