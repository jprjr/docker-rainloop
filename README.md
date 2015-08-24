# jprjr/rainloop

This is an Arch Linux-based image with [Rainloop](http://rainloop.net) (a webmail client) installed.

It's running as a FastCGI app, listening on port 9000. You'll need to run
some kind of proxy, like nginx or lighttpd. I have an example script + config
for running this with lighttpd in this repo.


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
```
$ docker run -e NGINX=1 -d -v /path/to/perm/folder:/var/lib/rainloop/data -p 80 jprjr/rainloop
```

Alternatively, you should be able to use links and data-only containers for
persistence.

## Exposed ports

* 9000 (fastcgi port)
* 80 (optional built-in nginx)

## Exposed volumes

* `/usr/share/webapps/rainloop` (explicitly from the Dockerfile. You'll want your proxy to access this volume using --volumes-from or similar)
* `/var/lib/rainloop/data` 
