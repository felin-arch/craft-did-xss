FROM php:7.0.12-apache

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        libapache2-mod-security2 \
        vim \
        curl \
        git \
        libicu-dev \
        subversion \
        unzip \
        wget && \
    rm -r /var/lib/apt/lists/*

RUN docker-php-ext-install pdo pdo_mysql intl

COPY etc/apache/000-default.conf /etc/apache2/sites-available/

WORKDIR /var/www

RUN a2enmod security2
RUN mv /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf
RUN cd /etc/modsecurity && \
    git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git && \
    mv owasp-modsecurity-crs/crs-setup.conf.example owasp-modsecurity-crs/crs-setup.conf

RUN sed -i'' 's/t:none,\\/t:none, \\/' /etc/modsecurity/owasp-modsecurity-crs/rules/RESPONSE-950-DATA-LEAKAGES.conf
RUN echo '\n<IfModule security2_module>\n\
     Include /etc/modsecurity/owasp-modsecurity-crs/crs-setup.conf\n\
     Include /etc/modsecurity/owasp-modsecurity-crs/rules/*.conf\n\
</IfModule>' >> /etc/apache2/apache2.conf
