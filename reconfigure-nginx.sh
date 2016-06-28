#!/bin/sh

reconf_site() {
    for site in $*; do
        server_names="/etc/nginx/$(basename "$site")_sites.txt"
        echo "server_name" > "$server_names"
        cat "$site"       >> "$server_names"
        echo ";"          >> "$server_names"

        for domain in $(certbot-parse.sh "$site" ' '); do
            ssl_config="/etc/nginx/ssl/${domain}.conf"
            echo "ssl_certificate /etc/letsencrypt/live/${site}/fullchain.pem;"    > "$ssl_config"
            echo "ssl_certificate_key /etc/letsencrypt/live/${site}/privkey.pem;" >> "$ssl_config"
            echo "include ssl/ssl_common.conf;"                                   >> "$ssl_config"
        done
    done
}

if [ $# -gt 0 ]; then
    reconf_site $*
else
    reconf_site /etc/letsencrypt-domains/*
fi

# Needs service restart, nginx -s reload does not always reload the certificates.
nginx -t && service nginx restart && rm /var/tmp/letsencrypt/needs-restart
