FROM php:7.4-fpm

ARG user

RUN apt-get update
RUN apt-get install -y libpq-dev libpng-dev curl nano unzip zip git jq supervisor
RUN docker-php-ext-install pdo_pgsql
RUN pecl install -o -f redis
RUN docker-php-ext-enable redis

RUN apt-get -y update && apt-get -y install build-essential autoconf libcurl4-openssl-dev --no-install-recommends

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && chmod +x /usr/local/bin/

RUN useradd -G www-data,root -u 1000 -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

RUN mkdir -p /home/apm-agent && \
    cd /home/apm-agent && \
    git clone https://github.com/elastic/apm-agent-php.git apm && \
    cd apm/src/ext && \
    /usr/local/bin/phpize && ./configure --enable-elastic_apm && \
    make clean && make && make install

COPY ./php/elastic_apm.ini /usr/local/etc/php/conf.d/elastic_apm.ini

WORKDIR /var/www/

USER $user

EXPOSE 80