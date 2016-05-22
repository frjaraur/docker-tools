#!/bin/bash
[ $# -lt 1 ] && echo "Needs at least UCP IP for getting your admin bundle!!!" && exit 1
UCP_FQDN=$1
UCP_ADMIN_PASSWORD="orca"
[ -n "$2" ] && UCP_ADMIN_PASSWORD=$2

echo -e "UCP_FQDN=${UCP_FQDN}\nUCP_ADMIN_PASSWORD=${UCP_ADMIN_PASSWORD}"

which unzip >/dev/null 2>&1 || ( echo "Unzip is a requeriment, please install 'zip'" && exit )

if [ $(which jq >/dev/null 2>&1 || echo 1)  -a  ! -x jq ] 
then
	wget -qq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -O jq
	chmod 755 jq
fi

AUTHTOKEN=$(curl -sk -d "{\"username\":\"admin\",\"password\":\"${UCP_ADMIN_PASSWORD}\"}" https://${UCP_FQDN}/auth/login | ./jq -r .auth_token)

curl -sk -H "Authorization: Bearer $AUTHTOKEN" https://${UCP_FQDN}/api/clientbundle -o bundle.zip >/dev/null 2>&1

unzip  -qqo bundle.zip 2>/dev/null

rm bundle.zip

curl -sk https://${UCP_FQDN}/ca > ucp-ca.pem

