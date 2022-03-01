#!/usr/bin/env bash

declare -A params=$6       # Create an associative array
declare -A headers=${9}    # Create an associative array
declare -A rewrites=${10}  # Create an associative array
paramsTXT=""
if [ -n "$6" ]; then
   for element in "${!params[@]}"
   do
      paramsTXT="${paramsTXT}
      fastcgi_param ${element} ${params[$element]};"
   done
fi
headersTXT=""
if [ -n "${9}" ]; then
   for element in "${!headers[@]}"
   do
      headersTXT="${headersTXT}
      add_header ${element} ${headers[$element]};"
   done
fi
rewritesTXT=""
if [ -n "${10}" ]; then
   for element in "${!rewrites[@]}"
   do
      rewritesTXT="${rewritesTXT}
      location ~ ${element} { if (!-f \$request_filename) { return 301 ${rewrites[$element]}; } }"
   done
fi

if [ "$7" = "true" ]
then configureXhgui="
location /xhgui {
        try_files \$uri \$uri/ /xhgui/index.php?\$args;
}
"
else configureXhgui=""
fi

block="map \$http_upgrade \$connection_upgrade {
       default upgrade;
       ''      close;
   }

   server {
       listen ${3:-80};
       listen [::]:${3:-80};
       server_name .$1;
       server_tokens off;
       root \"$2\";

       index index.php;

       charset utf-8;

       location /index.php {
           try_files /not_exists @octane;
       }

       location / {
           try_files \$uri \$uri/ @octane;
       }

       location = /favicon.ico { access_log off; log_not_found off; }
       location = /robots.txt  { access_log off; log_not_found off; }

       access_log off;
       error_log  /var/log/nginx/domain.com-error.log error;

       error_page 404 /index.php;

       location @octane {
           set \$suffix \"\";

           if (\$uri = /index.php) {
               set \$suffix ?\$query_string;
           }

           proxy_http_version 1.1;
           proxy_set_header Host \$http_host;
           proxy_set_header Scheme \$scheme;
           proxy_set_header SERVER_PORT \$server_port;
           proxy_set_header REMOTE_ADDR \$remote_addr;
           proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
           proxy_set_header Upgrade \$http_upgrade;
           proxy_set_header Connection \$connection_upgrade;

           proxy_pass http://127.0.0.1:8000\$suffix;
       }
   }
"

echo "$block" > "/etc/nginx/sites-available/$1"
ln -fs "/etc/nginx/sites-available/$1" "/etc/nginx/sites-enabled/$1"
