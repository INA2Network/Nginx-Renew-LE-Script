#!/bin/sh

reconf_site() {
    for site in $*; do
        config_file="/tmp/$(basename "$site")_sites.txt"
        ( echo "server_name"; cat "$site"; echo ";" ) > "$config_file"
    done
}

if [ $# -gt 0 ]; then
    reconf_site $*
else
    reconf_site /etc/letsencrypt-domains/*
fi

# Needs service restart, nginx -s reload does not always reload the certificates.
nginx -t && service nginx restart && rm /var/tmp/letsencrypt/needs-restart
