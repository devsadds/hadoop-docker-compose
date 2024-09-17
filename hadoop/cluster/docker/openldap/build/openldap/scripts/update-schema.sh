#!/usr/bin/env bash
cd /etc/ldap/extraschema/ldap

export SCHEMAS="kerberos.schema sudo.schema"
bash 2.5-schema-ldif.sh
ls /etc/ldap/extraschema/ldap | egrep '(kerberos.ldif|sudo.ldif)'

mv /etc/ldap/extraschema/ldap/{kerberos.ldif,sudo.ldif} /etc/ldap/schema
chown openldap:openldap /etc/ldap/schema/{kerberos.ldif,sudo.ldif}
chmod 0644 /etc/ldap/schema/{kerberos.ldif,sudo.ldif}

cat <<'OEF'> /tmp/2.5-add-schemas.ldif
include: file:///etc/ldap/schema/kerberos.ldif
include: file:///etc/ldap/schema/sudo.ldif
OEF

echo 'Exec ldapadd -QY EXTERNAL -H ldapi:/// -w ${LDAP_ADMIN_PASSWORD}  -f /tmp/2.5-add-schemas.ldif'

ldapadd -QY EXTERNAL -H ldapi:/// -w ${LDAP_ADMIN_PASSWORD}  -f /tmp/2.5-add-schemas.ldif