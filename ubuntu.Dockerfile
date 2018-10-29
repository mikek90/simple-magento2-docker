FROM ubuntu:18.04

ENV USER_NAME=magento
ENV USER_GROUP=www-data
ENV COMPOSER_FOLDER=/home/$USER_NAME/.composer/

WORKDIR /root

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y zip unzip apache2 curl wget

RUN apt-get install -y software-properties-common \
    && add-apt-repository ppa:ondrej/php \
    && apt-get update \
    && apt-get install -y php7.1 libapache2-mod-php7.1 php7.1-mcrypt php7.1-cli php7.1-xml php7.1-zip php7.1-mysql php7.1-gd php7.1-imagick php7.1-recode php7.1-tidy php7.1-xmlrpc php7.1-mbstring php7.1-intl php7.1-xsl php7.1-soap php7.1-bcmath php7.1-curl php7.1-dom

RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
RUN a2enmod rewrite

RUN service apache2 restart

RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

WORKDIR /var/www/html

RUN useradd -g $USER_GROUP -s /bin/bash -p $USER_NAME -m $USER_NAME

COPY ./auth.json $COMPOSER_FOLDER
RUN chown -R $USER_NAME:$USER_GROUP $COMPOSER_FOLDER \
    && chmod -R 775 $COMPOSER_FOLDER

RUN rm index.html
RUN chown -R $USER_NAME:$USER_GROUP /var/www
RUN su $USER_NAME -c "composer create-project --repository=https://repo.magento.com/ magento/project-community-edition /var/www/html"

# RUN find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} + \
#     && find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} + \
#     && chown -R :www-data . \
#     && chmod u+x bin/magento

# RUN su $USER_NAME -c "cd /var/www/html && php bin/magento cron:install"

EXPOSE 80
CMD apachectl -D FOREGROUND
