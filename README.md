# Simple Magento 2 docker
Simple and straightforward Magento 2 docker environment.

Magento docker image is built on `php:7.1-apache` and implements instructions from [Magento devdocs](https://devdocs.magento.com/guides/v2.2/install-gde/composer.html) only.
Docker compose also adds MySql and phpMyAdmin to provide complete hosting environment.

## Running solution
* Run `sudo docker-compose up -d` in your console.
* To open Magento go to `localhost:8000`.
* To open phpMyAdmin go to `localhost:8001`.

## System requirements
* Docker and `docker-compose` installed.

## Additional info
`auth.json` file is from https://github.com/alexcheng1982/docker-magento2