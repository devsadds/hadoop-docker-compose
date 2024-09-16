

FROM ubuntu-jammy:v1.0.0
RUN apt-get update && apt-get install -y ntp krb5-admin-server krb5-kdc krb5-kdc-ldap ldap-utils file dumb-init libpam-krb5 libsasl2-modules-gssapi-mit krb5-pkinit  wamerican

RUN rm -rf /var/lib/krb5kdc /etc/krb5kdc/ \
    && mkdir -pv /var/log/kerberos/ /var/lib/krb5kdc /etc/kerberos/krb5kdc \
    && touch /var/log/kerberos/krb5.log /var/log/kerberos/kadmin.log /var/log/kerberos/krb5lib.log

ENV KRB5_CONFIG=/etc/krb5.conf
ENV KRB5_KDC_PROFILE=/etc/kerberos/krb5kdc/kdc.conf

COPY starter.sh /opt/starter.sh
RUN chmod +x /opt/starter.sh \
    && ln -sfr $(which dumb-init) /usr/local/bin/dumb-init

EXPOSE 88 749


ENTRYPOINT ["/usr/local/bin/dumb-init", "--", "/opt/starter.sh"]


CMD ["krb5kdc", "-d", "/var/lib/krb5kdc/database", "-n" ]