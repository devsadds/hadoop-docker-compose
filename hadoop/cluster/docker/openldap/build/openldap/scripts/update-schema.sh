#!/usr/bin/env bash
cd /etc/ldap/extraschema/ldap

SCHEMAS="kerberos.schema sudo.schema"
bash /tmp/2.5-schema-ldif.sh
ls ~/ldap | egrep '(kerberos.ldif|sudo.ldif)'

mv ~/ldap/{kerberos.ldif,sudo.ldif} /etc/ldap/schema
chown openldap:openldap /etc/ldap/schema/{kerberos.ldif,sudo.ldif}
chmod 0644 /etc/ldap/schema/{kerberos.ldif,sudo.ldif}

cat <<'OEF'> /tmp/2.5-add-schemas.ldif
include: file:///etc/ldap/schema/kerberos.ldif
include: file:///etc/ldap/schema/sudo.ldif
OEF

echo 'Exec ldapadd -QY EXTERNAL -H ldapi:/// -w ${LDAP_ADMIN_PASSWORD}  -f /tmp/2.5-add-schemas.ldif'

ldapadd -QY EXTERNAL -H ldapi:/// -w ${LDAP_ADMIN_PASSWORD}  -f /tmp/2.5-add-schemas.ldif