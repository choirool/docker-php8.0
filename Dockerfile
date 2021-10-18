FROM debian:10.9-slim

LABEL maintainer "Choirool"

ARG DEBIAN_FRONTEND=noninteractive

# Install basic packages
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    build-essential \
    ca-certificates \
    curl \
    git \
    libgtk-3-0 \
    lsb-release \
    openssh-client \
    poppler-utils \
    unzip \
    wget

# Add key and repository
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

# Install PHP
RUN apt-get update && apt-get install -y php8.0-fpm php8.0-bcmath php8.0-cli php8.0-curl php8.0-mbstring php8.0-dom php8.0-xdebug php8.0-tidy php8.0-gd php8.0-zip php8.0-sqlite php-redis && \
    php -m && \
    php -v

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    mv composer.phar /usr/local/bin/composer && \
    php -r "unlink('composer-setup.php');" && \
    composer --version

RUN PHP_SC_VERSION=$(curl -s "https://api.github.com/repos/fabpot/local-php-security-checker/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/;s/^v//') && \
    curl -LSs https://github.com/fabpot/local-php-security-checker/releases/download/v${PHP_SC_VERSION}/local-php-security-checker_${PHP_SC_VERSION}_linux_amd64 > /usr/local/bin/local-php-security-checker && \
    chmod +x /usr/local/bin/local-php-security-checker && \
    unset PHP_SC_VERSION