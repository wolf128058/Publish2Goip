#!/bin/bash

## filename      goip.sh
##
## description:  check your public ipv4/ipv6
##               and set your goip-dynamic host to that
##
## author:       jonas.hess@mailbox.org
## =======================================================================

# CONFIG
$GOIPUSER="myusername"
$GOIPPASS="myverysecretpassword"
$GOIPHOST="myhost.goip.de"
$EXTLANIF="enp1s0"

check_ipv4_address() {
  if [ -n "$1" -a -z "${*##*\.*}" ]; then
    ipcalc $1 | awk 'BEGIN{FS=":";is_invalid=0} /^INVALID/ {is_invalid=1; print $1} END{exit is_invalid}'
    return $(echo $?)
  else
    echo "EMPTY OR INVALID ADDRESS"
    return 125
  fi
}

check_ipv6_address() {
  if [ -n "$1" -a -z "${*##*\:*}" ]; then
    ipv6calc -I ipv6addr -O ipv6addr $1 | awk 'BEGIN{FS=":";is_invalid=0} /^Error/ {is_invalid=1; print $1} END{exit is_invalid}'
    return $(echo $?)
  else
    echo "EMPTY OR INVALID ADDRESS"
    return 125
  fi
}

PublicIPv4=$(curl --interface $EXTLANIF -4 https://icanhazip.com)
PublicIPv6=$(curl --interface $EXTLANIF -6 https://icanhazip.com)

CheckV4=$(check_ipv4_address $PublicIPv4)
CheckV6=$(check_ipv6_address $PublicIPv6)

if [ -n "$CheckV4"]; then
  echo "IPv4 address "$PublicIPv4" is valid."
  curl "https://www.goip.de/setip?username="$GOIPUSER"&password="$GOIPPASS"&subdomain="$GOIPHOST"&ip="$PublicIPv4
else
  echo "IPv4 address "$PublicIPv4" is invalid!"
  echo ">> "$CheckV4
  echo "I will not publish it!"
fi

if [ -n "$CheckV6"]; then
  echo "IPv6 address "$PublicIPv6" is valid."
  curl "https://www.goip.de/setip?username="$GOIPUSER"&password="$GOIPPASS"&subdomain="$GOIPHOST"&ip6="$PublicIPv6
else
  echo "IPv6 address "$PublicIPv6" is invalid!"
  echo ">> "$CheckV6
  echo "I will not publish it!"
fi
