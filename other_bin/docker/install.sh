#!/bin/bash

test -e /etc/my_common || {
	mkdir /etc/my_common
}

test -e /etc/my_common/officialbin || {
	mkdir /etc/my_common/officialbin
}

curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /etc/my_common/officialbin/docker-compose
chmod +x /etc/my_common/officialbin/docker-compose

