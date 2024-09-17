FROM osixia/openldap:1.5.0
RUN mkdir -p /etc/ldap/extraschema/ldap
COPY ./schema/kerberos.schema /etc/ldap/extraschema/ldap/kerberos.schema
COPY ./schema/sudo.schema /etc/ldap/extraschema/ldap/sudo.schema
COPY ./scripts/2.5-schema-ldif.sh /etc/ldap/extraschema/ldap/2.5-schema-ldif.sh
COPY ./scripts/update-schema.sh /etc/ldap/extraschema/update-schema.sh