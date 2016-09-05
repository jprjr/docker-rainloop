FROM jprjr/php-fpm
MAINTAINER John Regan <john@jrjrtech.com>

USER root
RUN bash -c 'dirmngr &' && \
    pacman-key --init && \
    pacman-key --populate archlinux && \
    pacman-key --refresh-keys && \
    pacman -Syyu --noconfirm --quiet >/dev/null
RUN pacman -S --noconfirm --quiet --needed unzip nginx rsync make gcc >/dev/null

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
    chown -R http:http /usr/share/webapps && \
    # Add symlink so that people can override certain files in the rainloop data folder (for instance, use a custom favicon) without having to worry about version numbers
    ln -s /usr/share/webapps/rainloop/rainloop/v/* /usr/share/webapps/rainloop-latest

RUN mkdir -p /etc/s6/rainloop && \
    ln -s /bin/true /etc/s6/rainloop/finish && \
    mkdir -p /etc/s6/nginx && \
    ln -s /bin/true /etc/s6/nginx/finish

# Install imapproxy from squirrelmail. The latest version is from 2010, so this isn't frequently updated
ENV IMAP_PROXY_VERSION 1.2.7
RUN mkdir -p /etc/s6/imapproxy && \
    curl "http://vorboss.dl.sourceforge.net/project/squirrelmail/imap_proxy/$IMAP_PROXY_VERSION/squirrelmail-imap_proxy-$IMAP_PROXY_VERSION.tar.gz" \
    -o '/root/squirrelmail-imap_proxy.tar.gz' && \
    cd /root && \
    tar xf squirrelmail-imap_proxy.tar.gz && \
    cd squirrelmail-imap_proxy-* && \
    ./configure && make && make install

# Enabling the opcache PHP extension, so that PHP opcodes get cached (gives a major performance boost)
RUN echo 'zend_extension=opcache.so;' > /etc/php/conf.d/opcache.ini && \
    echo 'opcache.enable=1;' >> /etc/php/conf.d/opcache.ini

# Setting the max upload size to 1024M. The default is 2M, but that's not great for big email attachments.
# If you want to change this, simply add a volume to your container pointing to (and thereby overwriting) /etc/php/conf.d/uploads.ini
RUN echo 'upload_max_filesize = 1024M' > /etc/php/conf.d/uploads.ini && \
    echo 'post_max_size = 1024M' >> /etc/php/conf.d/uploads.ini

# Removing build environment. If, at some point, a vulnerability is found Rainloop that allows for code
# execution, we don't want a compiler laying around - although this will probably only stop a script kiddie
RUN pacman -R --noconfirm make gcc

COPY rainloop.run /etc/s6/rainloop/run
COPY nginx.run /etc/s6/nginx/run
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY imapproxy.run /etc/s6/imapproxy/run
COPY conf/imapproxy.conf /etc/imapproxy.conf.default

VOLUME /usr/share/webapps/rainloop
VOLUME /var/lib/rainloop/data

ENTRYPOINT ["/usr/bin/s6-svscan","/etc/s6"]
CMD []
