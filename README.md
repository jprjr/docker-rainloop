# jprjr/rainloop

This is an Arch Linux-based image with [Rainloop](http://rainloop.net) (a webmail client) installed.

It's running as a FastCGI app, listening on port 9000. You'll need to run
some kind of proxy, like nginx or lighttpd. I have an example script + config
for running this with lighttpd in this repo, or you can run the built-in nginx server
and either publish it directly or point your webserver to it as a reverse proxy.


## Usage

### Build

```
$ docker build -t <repo name> .
```

### Run in foreground
```
$ docker run -v /path/to/perm/folder:/var/lib/rainloop/data -p 9000 jprjr/rainloop
```

### Run with built-in NGINX
This image comes with NGINX set up already, in case you don't want to run your own web server that in turn contacts rainloop via fastcgi. To start the built-in NGINX server, set the NGINX environment variable to 1, like so:

```
$ docker run -e NGINX=1 -d -v /path/to/perm/folder:/var/lib/rainloop/data -p 80 jprjr/rainloop
```

Alternatively, you should be able to use links and data-only containers for
persistence.

### Starting the IMAP proxy

Many webmail clients, including rainloop, have a common problem where they connect and disconnect from IMAP all the time, instead of keeping a persistent connection open. This happens mainly because rainloop is a PHP-based web application, and it doesn't currently support push (RainLoop/rainloop-webmail#215). If you don't want to agitate your IMAP server by repeatedly connecting to it (or if is spamming your log file), a simple solution is an IMAP proxy. One is included in this container, and setting it up is as simple as setting the IMAP_PROXY environment variable and pointing it to the IMAP server you want to connect to:

```
$ docker run -e IMAP_PROXY=mail.example.com -d -v /path/to/perm/folder:/var/lib/rainloop/data jprjr/rainloop
```

In the example above, the IMAP proxy will connect to the IMAP server on mail.example.com, and listen on 127.0.0.1:143. In the rainloop admin interface, set up your domain to point to 127.0.0.1 instead of directly to mail.example.com. Even if your IMAP server uses SSL or STARTTLS, you should set the security level to 'None' in rainloop (the IMAP proxy will still use SSL/TLS for the connection if needed, even if the connection between rainloop and the IMAP proxy won't).

When using this proxy, repeated connections to your IMAP server will stay open until a connection has been inactive for 5 minutes. It will not provide rainloop with push support.

### 

## Exposed ports

* 9000 (fastcgi/php-fpm port)
* 80 (optional built-in nginx)

## Exposed volumes

* `/usr/share/webapps/rainloop` (explicitly from the Dockerfile. If you're not using NGINX=1 you'll want your proxy to access this volume using --volumes-from or similar)
* `/var/lib/rainloop/data` (you'll want to mount this volume to a local directory with -v in order for it to survive container upgrades, as all the rainloop data resides here)
