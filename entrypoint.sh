#!/bin/bash
# vfeeg-postfix mailgateway EEG Faktura
# Copyright (C) 2023 VFEEG
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

echo "Configuring postfix"

if [ "$POSTFIX_RELAY_PASSWORD" == "" ] && [ "$POSTFIX_RELAY_PASSWORD_FILE" != "" ] && [ -f "$POSTFIX_RELAY_PASSWORD_FILE" ]; then
  POSTFIX_RELAY_PASSWORD=`head -n 1 "$POSTFIX_RELAY_PASSWORD_FILE"`
fi

if [ "POSTFIX_RELAY_HOST" != "" ] && [ "$POSTFIX_RELAY_USER" != "" ] && [ "$POSTFIX_RELAY_PASSWORD" != "" ]; then

  echo "[${POSTFIX_RELAY_HOST}]:${POSTFIX_RELAY_PORT:-587} ${POSTFIX_RELAY_USER}:${POSTFIX_RELAY_PASSWORD}" > /etc/postfix/sasl_password
  postmap /etc/postfix/sasl_password

  postconf -e "smtp_sasl_auth_enable = yes"
  postconf -e "smtp_sasl_password_maps = hash:/etc/postfix/sasl_password"
  postconf -e "smtp_sasl_security_options = noanonymous"

else
  postconf -e "smtp_sasl_auth_enable = no"
fi

#override from email address
if  [ "POSTFIX_RELAY_EMAIL" != "" ]; then
  echo "/.+/ ${POSTFIX_RELAY_EMAIL}" > /etc/postfix/sender_canonical_maps
  echo "/From:.*/ REPLACE From: ${POSTFIX_RELAY_EMAIL}" > /etc/postfix/header_check
  postconf -e "sender_canonical_classes = envelope_sender,header_sender"
  postconf -e "sender_canonical_maps =  regexp:/etc/postfix/sender_canonical_maps"
  postconf -e "smtp_header_checks = regexp:/etc/postfix/header_check"
fi

postconf -e "inet_protocols = ipv4"
postconf -e "maillog_file = /dev/stdout"
postconf -e "mydestination = ${POSTFIX_HOSTNAME:-localhost}"
postconf -e "mydomain = ${POSTFIX_MYDOMAIN:-localdomain}"
postconf -e "myhostname =${POSTFIX_HOSTNAME:-localhost}.${POSTFIX_MYDOMAIN:-localdomain}"
postconf -e "mynetworks = ${POSTFIX_MYNETWORK:-192.168.0.0/16,172.16.0.0/12}"
postconf -e "myorigin = ${POSTFIX_MYDOMAIN}"

if [ "$POSTFIX_RELAY_TLS" != "" ]; then
  if [ "$POSTFIX_RELAY_TLS" == "yes" ]; then
    postconf -e "relayhost = [${POSTFIX_RELAY_HOST}]:${POSTFIX_RELAY_PORT:-587}"
    postconf -e "smtp_use_tls = yes"
  else
    postconf -e "relayhost = [${POSTFIX_RELAY_HOST}]:${POSTFIX_RELAY_PORT:-25}"
    postconf -e "smtp_use_tls = no"
  fi
else
  postconf -e "relayhost = [${POSTFIX_RELAY_HOST}]:${POSTFIX_RELAY_PORT:-587}"
  postconf -e "smtp_use_tls = yes"
fi

postconf -e "smtp_host_lookup = native,dns"

echo "nameserver ${POSTFIX_DNS_1}" > /var/spool/postfix/etc/resolv.conf
echo "nameserver ${POSTFIX_DNS_1}" > /etc/resolv.conf

if [ "$POSTFIX_DNS_2" != "" ]; then
  echo "nameserver ${POSTFIX_DNS_2}" > /var/spool/postfix/etc/resolv.conf
  echo "nameserver ${POSTFIX_DNS_2}" > /etc/resolv.conf
fi

echo "Starting postfix"
exec /usr/sbin/postfix start-fg