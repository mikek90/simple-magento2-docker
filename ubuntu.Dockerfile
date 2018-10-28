FROM ubuntu:18.04

# # COPY ./configure.sh .
# # RUN chmod a+x configure.sh
# # RUN bash configure.sh

WORKDIR /root

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y zip unzip mc apache2 curl wget build-essential

RUN apt-get install -y software-properties-common \ 
    && add-apt-repository ppa:ondrej/php \
    && apt-get update \
    && apt-get install -y php7.1 libapache2-mod-php7.1 php7.1-mcrypt php7.1-cli php7.1-xml php7.1-zip php7.1-mysql php7.1-gd php7.1-imagick php7.1-recode php7.1-tidy php7.1-xmlrpc php7.1-mbstring php7.1-intl php7.1-xsl php7.1-soap php7.1-bcmath php7.1-curl php7.1-dom

RUN service apache2 restart

# RUN update-alternatives --set php /usr/bin/php7.1 \
#     && update-alternatives --set phar /usr/bin/phar7.1 \
#     && update-alternatives --set phar.phar /usr/bin/phar.phar7.1

# auth.json from https://github.com/alexcheng1982/docker-magento2/blob/master/auth.json
COPY ./auth.json /var/www/.composer/
COPY ./auth.json /root/.composer/

RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

WORKDIR /var/www/html

RUN rm index.html
RUN chsh -s /bin/bash www-data
RUN chown -R www-data:www-data /var/www
RUN su www-data -c "composer create-project --repository=https://repo.magento.com/ magento/project-community-edition /var/www/html"

EXPOSE 80
CMD apachectl -D FOREGROUND