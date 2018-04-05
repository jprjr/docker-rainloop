# olemartinorg/rainloop

This is an image with [Rainloop](http://rainloop.net) (a webmail client) installed.

## Usage

### Build

```
$ docker build -t rainloop .
```

### Starting

```
$ docker run -d -v /path/to/perm/folder:/var/lib/rainloop/data -p 80 rainloop
```

Alternatively, you should be able to use links and data-only containers for
persistence.

## Exposed ports

* 80 (nginx)
