FROM osixia/openldap:1.5.0
RUN mkdir -p /etc/ldap/extraschema/ldap
COPY ./schema/kerberos.schema /etc/ldap/extraschema/kerberos.schema
COPY ./schema/sudo.schema /etc/ldap/extraschema/sudo.schema
COPY ./scripts/2.5-schema-ldif.sh /etc/extraschema/2.5-schema-ldif.sh
COPY ./scripts/update-schema.sh /etc/extraschema/update-schema.sh