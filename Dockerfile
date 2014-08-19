FROM jprjr/php-fpm
MAINTAINER John Regan <john@jrjrtech.com>

USER root
RUN pacman -Syy --noconfirm --quiet > /dev/null
RUN pacman -S --noconfirm --quiet --needed unzip \
    nginx rsync > /dev/null

RUN sed -i '/^open_basedir/c \
open_basedir = /usr/share/webapps/rainloop/:/tmp/:/usr/share/pear/:/var/lib/rainloop/' /etc/php/php.ini

RUN mkdir -p /usr/share/webapps/rainloop && \
    mkdir -p /var/lib/rainloop &&  \
    cd /usr/share/webapps/rainloop && \
    curl -R -L -O \
    "http://repository.rainloop.net/v1/rainloop-latest.zip" && \
    unzip rainloop-latest.zip && rm rainloop-latest.zip && \
    mv data /usr/share/webapps/rainloop-default-data  && \
    ln -s /var/lib/rainloop/data /usr/share/webapps/rainloop/data && \
    chown -R http:http /var/lib/rainloop && \
    chown -R http:http /usr/share/webapps

RUN mkdir -p /etc/s6/rainloop && \
    ln -s /bin/true /etc/s6/rainloop/finish && \
    mkdir -p /etc/s6/nginx && \
    ln -s /bin/true /etc/s6/nginx/finish
    
COPY rainloop.run /etc/s6/rainloop/run
COPY nginx.run /etc/s6/nginx/run
COPY conf/nginx.conf /etc/nginx/nginx.conf

VOLUME /usr/share/webapps/rainloop
VOLUME /var/lib/rainloop/data

ENTRYPOINT ["/usr/bin/s6-svscan","/etc/s6"]
CMD []
