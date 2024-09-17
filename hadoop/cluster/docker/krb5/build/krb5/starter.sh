#!/usr/bin/env bash

krb_database_name=$(grep database_name ${KRB5_KDC_PROFILE}  | awk -F'=' '{print $2}' |  awk -F'/' '{print $NF}')

if file /var/lib/krb5kdc/${krb_database_name} | grep -qo Berkeley; then 
    echo "ok. Database ${krb_database_name} exitst IN /var/lib/krb5kdc"
else
    echo "Init database ${krb_database_name} IN /var/lib/krb5kdc"
    cd /var/lib/krb5kdc
    kdb5_util create -r OMSK.LINUX2BE.COM -P ${KRB5_KDC_PASSWORD} -d ${krb_database_name} -s
fi

"$@"
