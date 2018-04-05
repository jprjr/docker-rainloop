FROM ubuntu:xenial

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install curl unzip nginx php-cli php-fpm php-opcache php-curl php-xml rsync supervisor supervisor && \
    echo 'open_basedir = /usr/share/webapps/rainloop/:/tmp/:/usr/share/pear/:/var/lib/rainloop/' >> /etc/php/7.0/cli/conf.d/rainloop.ini && \
    echo 'open_basedir = /usr/share/webapps/rainloop/:/tmp/:/usr/share/pear/:/var/lib/rainloop/' >> /etc/php/7.0/fpm/conf.d/rainloop.ini && \
    mkdir -p /run/php && \
    mkdir -p /usr/share/webapps/rainloop && \
    mkdir -p /var/lib/rainloop &&  \
    cd /usr/share/webapps/rainloop && \
    curl -R -L -o rainloop-latest.zip $( \
        curl -L https://api.github.com/repos/RainLoop/rainloop-webmail/releases | \
            php -r 'echo current(array_filter(current(array_filter(json_decode(file_get_contents("php://stdin"), true), function($a){return !$a["prerelease"];}))["assets"], function($b){return preg_match("/^rainloop-community.*?zip\$/", $b["name"]);}))["browser_download_url"];' \
    ) && \
    unzip rainloop-latest.zip && rm rainloop-latest.zip && \
    mv data /usr/share/webapps/rainloop-default-data  && \
    ln -s /var/lib/rainloop/data /usr/share/webapps/rainloop/data && \
    chown -R www-data:www-data /var/lib/rainloop && \
    chown -R www-data:www-data /usr/share/webapps && \
    chmod -R 700 /usr/share/webapps && \
    echo 'upload_max_filesize = 1024M' > /etc/php/7.0/fpm/conf.d/uploads.ini && \
    echo 'post_max_size = 1024M' >> /etc/php/7.0/fpm/conf.d/uploads.ini && \
    echo '[supervisord]' > /etc/supervisor/conf.d/supervisord.conf && \
    echo 'nodaemon=true' >> /etc/supervisor/conf.d/supervisord.conf && \
    rm -rf /var/lib/apt/lists/*

COPY start.sh /start.sh
COPY conf/supervisor-nginx.conf /etc/supervisor/conf.d/
COPY conf/supervisor-php-fpm.conf /etc/supervisor/conf.d/
COPY conf/nginx.conf /etc/nginx/nginx.conf

VOLUME /usr/share/webapps/rainloop
VOLUME /var/lib/rainloop/data

CMD /start.sh
