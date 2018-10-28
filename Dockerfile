FROM php:7.1-apache

# auth.json from https://github.com/alexcheng1982/docker-magento2/blob/master/auth.json
COPY ./auth.json /root/.composer/

RUN apt-get update \
    && apt-get install -y zip unzip \
    && apt-get install -y libmcrypt-dev libmcrypt4 libcurl3-dev libfreetype6 libfreetype6-dev libicu-dev libxslt1-dev libjpeg62-turbo-dev

RUN docker-php-ext-install pdo_mysql \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && docker-php-ext-install mcrypt mbstring zip intl xsl soap bcmath

RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

RUN composer create-project --repository=https://repo.magento.com/ magento/project-community-edition /var/www/html

RUN find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} + \
    && find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} + \
    && chown -R :www-data . \
    && chmod u+x bin/magento
