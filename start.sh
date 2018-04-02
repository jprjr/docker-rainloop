#!/usr/bin/env bash

function setup_nginx {
    if [[ ! -f /usr/share/webapps/rainloop/custom.css ]]; then
        # Remove all lines starting with 'sub_filter' from the nginx.conf if
        # you dont have any custom.css file mounted as a volume
        sed -r -i '/^\s+sub_filter/d' /etc/nginx/nginx.conf
    fi
    unset NGINX
}

function setup_rainloop {
    mkdir -p /var/lib/rainloop/data

    rainloop_files=(/var/lib/rainloop/data/*)
    (( ${#rainloop_files[*]} )) && need_setup_rainloop=0 || need_setup_rainloop=1

    if [[ $need_setup_rainloop -eq 1 ]]; then
        rsync -av /usr/share/webapps/rainloop-default-data/ /var/lib/rainloop/data/
    fi
}

setup_nginx
setup_rainloop
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
