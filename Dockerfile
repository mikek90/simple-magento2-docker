FROM php:7.1-apache

ENV USER_NAME=magento
ENV USER_GROUP=www-data
ENV COMPOSER_FOLDER=/home/$USER_NAME/.composer/

RUN useradd -g $USER_GROUP -s /bin/bash -p $USER_NAME -m $USER_NAME

# auth.json from https://github.com/alexcheng1982/docker-magento2/blob/master/auth.json
COPY ./auth.json $COMPOSER_FOLDER
RUN chown -R $USER_NAME:$USER_GROUP $COMPOSER_FOLDER \
    && chmod -R 775 $COMPOSER_FOLDER

RUN apt-get update \
    && apt-get install -y zip unzip cron \
    && apt-get install -y libmcrypt-dev libmcrypt4 libcurl3-dev libfreetype6 libfreetype6-dev libicu-dev libxslt1-dev libjpeg62-turbo-dev

RUN docker-php-ext-install pdo_mysql \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && docker-php-ext-install mcrypt mbstring zip intl xsl soap bcmath

RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
RUN a2enmod rewrite

RUN service apache2 restart

RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

RUN chown -R $USER_NAME:$USER_GROUP /var/www
RUN su $USER_NAME -c "composer create-project --repository=https://repo.magento.com/ magento/project-community-edition /var/www/html"

RUN find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} + \
    && find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} + \
    && chown -R :www-data . \
    && chmod u+x bin/magento

# RUN su $USER_NAME -c "cd /var/www/html && php bin/magento cron:install"
