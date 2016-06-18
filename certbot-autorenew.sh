#!/bin/sh

# Must match /etc/nginx/conf.d/upstream_certbot80.conf
http_port=8800

# Must match /etc/nginx/conf.d/upstream_certbot443.conf
https_port=4433

# For testing as non-root
#extra_args="--staging --logs-dir ${HOME}/log --config-dir ${HOME}/config --agree-tos --email stribika@gmail.com"
extra_args="--quiet"

renew_cert() {
    for site in $*; do
        domains="$(sed -r 's/#.*//;s/ +//g;/^$/ d' "$site" | sed -r -z 's/\n(.)/,\1/g')"

        if [ -z "$domains" ]; then
            echo "no domains in $site"
        else
            certbot certonly --standalone --standalone-supported-challenges http-01 \
                --non-interactive --keep --expand \
                --domains "$domains" \
                --http-01-port "$http_port" --tls-sni-01-port "$https_port" \
                --post-hook 'touch /var/tmp/letsencrypt/needs-restart' \
                $extra_args
        fi
    done
}

mkdir -p /var/tmp/letsencrypt

if [ $# -gt 0 ]; then
    renew_cert $*
else
    renew_cert /etc/letsencrypt-domains/*
fi

if [ -e /var/tmp/letsencrypt/needs-restart ]; then
    # Needs service restart, nginx -s reload does not always reload the certificates.
    nginx -t && service nginx restart && rm /var/tmp/letsencrypt/needs-restart
fi
