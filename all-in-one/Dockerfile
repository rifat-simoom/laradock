ARG COPY_SOURCE=copy
ARG LARADOCK_PHP_VERSION
ARG BASE_IMAGE_TAG_PREFIX=latest



###########################################################################
# Copy Application
###########################################################################

FROM webdevops/php-apache:${LARADOCK_PHP_VERSION} as build_copy
ONBUILD ARG ALL_IN_ONE_DATA_APPLICATON_PATH=/softrobotics
ONBUILD ADD ${ALL_IN_ONE_DATA_APPLICATON_PATH} /var/www/
ONBUILD RUN echo "application copied"
FROM webdevops/php-apache:${LARADOCK_PHP_VERSION} as build_no_copy
ONBUILD RUN echo "no copy"



FROM build_${COPY_SOURCE}
LABEL maintainer="Rifat Simoom <rifat-simoomk@users.noreply.github.com>"

ARG LARADOCK_PHP_VERSION
# Set Environment Variables
ENV DEBIAN_FRONTEND noninteractive
ARG ALL_IN_ONE_DATA_PATH=./laradock-sr/all-in-one
ARG ALL_IN_ONE_DATA_APPLICATON_PATH=/softrobotics
ARG APP_ENVIRONMENT=*

###########################################################################
# File Editor
###########################################################################


RUN apt-get -y update
RUN apt-get -y install nano


###########################################################################
# Set Timezone
###########################################################################

ARG TZ=UTC
ENV TZ=${TZ}

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone



###########################################################################
# PHP
###########################################################################
#ADD ${ALL_IN_ONE_DATA_APPLICATON_PATH} /var/www/


RUN if [ "$APP_ENVIRONMENT" = "admin" ]; then \
        rm -rf /var/www/ccpayment && \
        rm -rf /var/www/merchant; \
    fi


RUN if [ "$APP_ENVIRONMENT" = "without-admin" ]; then \
        rm -rf /var/www/admin; \
    fi

RUN mkdir -p /var/www/common/system_cache && chown www-data:www-data /var/www/common/system_cache


COPY ${ALL_IN_ONE_DATA_PATH}/php${LARADOCK_PHP_VERSION}.ini /usr/local/etc/php/php.ini

COPY ${ALL_IN_ONE_DATA_PATH}/laravel.ini /usr/local/etc/php/conf.d

COPY ${ALL_IN_ONE_DATA_PATH}/xlaravel.pool.conf /usr/local/etc/php-fpm.d/

USER root

#Configure non-root user.

ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

RUN groupmod -o -g ${PGID} www-data && \
    usermod -o -u ${PUID} -g www-data www-data


# Configure locale.
ARG LOCALE=POSIX
ENV LC_ALL ${LOCALE}

WORKDIR /var/www

EXPOSE 9000

#CMD ["php-fpm"]




###########################################################################
# Apache
###########################################################################

ARG DOCUMENT_ROOT=/var/www/
ARG PHP_UPSTREAM_CONTAINER=all-in-one
ARG PHP_UPSTREAM_PORT=9000
ARG PHP_UPSTREAM_TIMEOUT=60
ARG APACHE_INSTALL_HTTP2=false
ARG APACHE_HOST_LOG_PATH=./logs/apache2
ARG APACHE_SITES_PATH=./apache2/sites
ARG APACHE_SSL_PATH=/etc/apache2/ssl/

#ENV WEB_PHP_SOCKET=${PHP_UPSTREAM_CONTAINER}:${PHP_UPSTREAM_PORT}
ENV WEB_DOCUMENT_ROOT=${DOCUMENT_ROOT}
ENV APACHE_HTTP2=${APACHE_INSTALL_HTTP2}
ENV WEB_PHP_TIMEOUT=${PHP_UPSTREAM_TIMEOUT}

RUN mkdir -p /var/log/apache2

ENV LOG_STDOUT=/var/log/apache2/access.log

ENV LOG_STDERR=/var/log/apache2/error.log

EXPOSE 80 443

WORKDIR /var/www/

RUN rm -rf /etc/apache2/sites-available/*

COPY ${APACHE_SITES_PATH}/* /etc/apache2/sites-available

COPY ${APACHE_SSL_PATH}/* /etc/apache2/ssl/

COPY ${ALL_IN_ONE_DATA_PATH}/vhost.conf /etc/apache2/sites-enabled/vhost.conf

ADD ${ALL_IN_ONE_DATA_PATH}/startup.sh /opt/startup.sh

ENTRYPOINT ["/opt/docker/bin/entrypoint.sh"]

#CMD ["/bin/bash", "/opt/startup.sh"]


EXPOSE 80 443

###########################################################################
# Config
###########################################################################


RUN if [ -f "/var/www/artisan" ]; then php /var/www/artisan config:cache; fi

RUN if [ -d "/var/www/admin" ]; then php /var/www/admin/artisan config:cache; fi

RUN if [ -d "/var/www/merchant" ]; then php /var/www/merchant/artisan config:cache; fi

RUN if [ -d "/var/www/ccpayment" ]; then php /var/www/ccpayment/artisan config:cache; fi



###########################################################################
# Permission
###########################################################################


RUN if [ -d "/var/www/common/system_cache" ]; then chmod -R 777 /var/www/common/system_cache; fi

RUN if [ -d "/var/www/storage" ]; then chmod -R 777 /var/www/storage; fi

RUN if [ -d "/var/www/admin/storage" ]; then chmod -R 777 /var/www/admin/storage; fi

RUN if [ -d "/var/www/merchant/storage" ]; then chmod -R 777 /var/www/merchant/storage; fi

RUN if [ -d "/var/www/ccpayment/storage" ]; then chmod -R 777 /var/www/ccpayment/storage; fi


RUN if [ -d "/var/www/brandresource" ]; then chmod -R 777 /var/www/brandresource; fi

RUN if [ -d "/var/www/public" ]; then chmod -R 777 /var/www/public; fi

RUN if [ -d "/var/www/admin/public" ]; then chmod -R 777 /var/www/admin/public; fi

RUN if [ -d "/var/www/merchant/public" ]; then chmod -R 777 /var/www/merchant/public; fi

RUN if [ -d "/var/www/ccpayment/public" ]; then chmod -R 777 /var/www/ccpayment/public; fi


###########################################################################
# Crontab
###########################################################################

USER root

RUN if [ "$APP_ENVIRONMENT" = "*" ] || [ "$APP_ENVIRONMENT" = "report" ] || [ "$APP_ENVIRONMENT" = "platform" ]; then \
        docker-service-enable cron; \
    fi
    
COPY  ${ALL_IN_ONE_DATA_PATH}/crontab /etc/cron.d


RUN if [ "$APP_ENVIRONMENT" = "platform" ]; then \
        rm -rf /etc/cron.d/report && \
        rm -rf /etc/cron.d/everything; \
    fi
    
RUN if [ "$APP_ENVIRONMENT" = "report" ]; then \
        rm -rf /etc/cron.d/platform && \
        rm -rf /etc/cron.d/everything; \
    fi
RUN if [ "$APP_ENVIRONMENT" = "*" ]; then \
        rm -rf /etc/cron.d/report && \
        rm -rf /etc/cron.d/platform; \
    fi

RUN if [ "$APP_ENVIRONMENT" = "*" ] || [ "$APP_ENVIRONMENT" = "report" ] || [ "$APP_ENVIRONMENT" = "platform" ]; then \
        chmod -R 644 /etc/cron.d; \
    fi


RUN if [ "$APP_ENVIRONMENT" != "*" ] && [ "$APP_ENVIRONMENT" != "report" ] && [ "$APP_ENVIRONMENT" != "platform" ]; then \
        docker-service-disable cron && \
        rm -rf /etc/cron.d/platform && \
        rm -rf /etc/cron.d/report && \
        rm -rf /etc/cron.d/everything; \
    fi



###########################################################################
# Supervisor
###########################################################################

COPY ${ALL_IN_ONE_DATA_PATH}/supervisord.conf /opt/docker/etc/supervisord-laravel.conf
COPY ${ALL_IN_ONE_DATA_PATH}/supervisord.d /opt/docker/etc/supervisor.d
COPY ${ALL_IN_ONE_DATA_PATH}/supervisor.sh /opt/docker/bin/service.d/entrypoint.d/11-supervisor.sh

RUN if [ "$APP_ENVIRONMENT" = "platform" ]; then \
        rm -rf /opt/docker/etc/supervisor.d/report.sr.conf && \
        rm -rf /opt/docker/etc/supervisor.d/everything.sr.conf; \
    fi
    
RUN if [ "$APP_ENVIRONMENT" = "report" ]; then \
        rm -rf /opt/docker/etc/supervisor.d/platform.sr.conf && \
        rm -rf /opt/docker/etc/supervisor.d/everything.sr.conf; \
    fi
    
RUN if [ "$APP_ENVIRONMENT" = "*" ]; then \
        rm -rf /opt/docker/etc/supervisor.d/report.sr.conf && \
        rm -rf /opt/docker/etc/supervisor.d/platform.sr.conf; \
    fi


RUN if [ "$APP_ENVIRONMENT" != "*" ] && [ "$APP_ENVIRONMENT" != "report" ] && [ "$APP_ENVIRONMENT" != "platform" ]; then \
        rm -rf /opt/docker/etc/supervisord-laravel.conf && \
        rm -rf /opt/docker/bin/service.d/entrypoint.d/11-supervisor.sh && \
        rm -rf /opt/docker/etc/supervisor.d/report.sr.conf && \
        rm -rf /opt/docker/etc/supervisor.d/everything.sr.conf && \
        rm -rf /opt/docker/etc/supervisor.d/platform.sr.conf; \
    fi



###########################################################################
# StartUp
###########################################################################
#CMD ["/bin/bash", "/opt/startup.sh"]
CMD ["supervisord"]
