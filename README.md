# Nginx-Renew-LE-Script

Script to renew LetsEncrypt certificates automatically across multiple VMs running Nginx

## Prerequisites

Certbot and Nginx must be installed.
Some distros have a certbot package, use that if you can.

## Installation

Copy certbot-autorenew.sh to /usr/local/sbin or some other location on $PATH.
Create the /etc/letsencrypt-domains directory.
Files in this directory correspond to certificates.
Certificates will be valid for every domain listed in these files (one per line).

*WARNING!*
If you have pre-existing certificates that are valid for some but not all the domains, or you already numbered domains (e.g. example.com-0001) in /etc/letsencrypt, then the script may renew the certificate every time it runs.
You should remove the files from /etc/letsencrypt/{archive,live,renew} and run the script again.
Be careful not to exceed the 20/week/domain quota with this.

You have to create an account manually with certbot.
(Or add --email and --agree-tos into the extra_args in the script.)

Finally, add the script to your crontab.
If you run it every 2 weeks or so, it should renew the certificates in time, even if you miss a few runs.

## Nginx configuration

You have to configure nginx to use the correct certificate, based on the SNI value.
Also, you have to forward requests to /.well-known/ to the server started by certbot.
You can use the include files you find in the /nginx/ sub-directory of this repo.

```
http {
    include upstream_certbot.conf;

    server {
        listen 80;
        server_name example.org www.example.org;
        include location_certbot80.conf;

        ...
    }

    server {
        listen 443 ssl;
        server_name example.org www.example.org;
        include ssl_example_org.conf;
        include location_certbot443.conf;

        ...
    }

    server {
        listen 80;
        server_name example.com www.example.com;
        include location_certbot80.conf;

        ...
    }

    server {
        listen 443 ssl;
        server_name example.com www.example.com;
        include ssl_example_com.conf;
        include location_certbot443.conf;

        ...
    }

    ...
}
```
