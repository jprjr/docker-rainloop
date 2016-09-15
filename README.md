# jprjr/rainloop

This is an Arch Linux-based image with [Rainloop](http://rainloop.net) (a webmail client) installed.

It's running as a FastCGI app, listening on port 9000. You'll need to run
some kind of proxy, like nginx or lighttpd. I have an example script + config
for running this with lighttpd in this repo, or you can run the built-in nginx server
and either publish it directly or point your webserver to it as a reverse proxy.


## Usage

Rainloop expects the data folder to have a certain layout. I've made a small
script to setup the data folder structure at `/opt/init_data_folder.sh` -
you should only have to do this once.

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

### 

## Exposed ports

* 9000 (fastcgi/php-fpm port)
* 80 (optional built-in nginx)

## Exposed volumes

* `/usr/share/webapps/rainloop` (explicitly from the Dockerfile. If you're not using NGINX=1 you'll want your proxy to access this volume using --volumes-from or similar)
* `/var/lib/rainloop/data` (you'll want to mount this volume to a local directory with -v in order for it to survive container upgrades, as all the rainloop data resides here)
