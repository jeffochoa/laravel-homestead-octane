#!/usr/bin/env bash

if [ -f ~/.homestead-features/swoole_user_name ]; then
    SWOOLE_USER_NAME="$(cat ~/.homestead-features/swoole_user_name)"
    WSL_USER_GROUP="$(cat ~/.homestead-features/swoole_user_group)"
else
    SWOOLE_USER_NAME=vagrant
    WSL_USER_GROUP=vagrant
fi

if [ -f /home/$SWOOLE_USER_NAME/.homestead-features/swoole ]
then
    echo "swoole already installed."
    exit 0
fi

touch /home/$SWOOLE_USER_NAME/.homestead-features/swoole
chown -Rf $SWOOLE_USER_NAME:$WSL_USER_GROUP /home/$SWOOLE_USER_NAME/.homestead-features

# INSTALL
yes | pecl install swoole

grep "extension=swoole.so" /etc/php/8.0/cli/php.ini || echo "extension=swoole.so" >> /etc/php/8.0/cli/php.ini
