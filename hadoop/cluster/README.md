# Full stack

## Prepare

```
make build_docker
docker-compose up -d openldap
docker-compose up -d phpldapadmin
```


## Ldap config

Создаем нужные схемы

```sh
/etc/ldap/extraschema/update-schema.sh
```

```sh
cat <<'OEF'> /tmp/1.ldif
dn: ou=People,dc=org,dc=example,dc=local
objectClass: organizationalUnit
ou: People

dn: cn=sa0000mmprod,ou=People,dc=org,dc=example,dc=local
objectClass: person
objectClass: inetOrgPerson
sn: sa0000mmprod
cn: sa0000mmprod
mail: sa0000mmprod@org.example.local
userpassword: sa0000mmprod
OEF

ldapadd -x -D cn=admin,dc=org,dc=example,dc=local  -w ${LDAP_ADMIN_PASSWORD} -f /tmp/1.ldif

cat <<'OEF'> /tmp/2.ldif
dn: cn=krbContainer,dc=org,dc=example,dc=local
objectClass: top
objectClass: krbContainer
cn: krbContainer
OEF

ldapadd -x -D cn=admin,dc=org,dc=example,dc=local  -w ${LDAP_ADMIN_PASSWORD} -f /tmp/2.ldif




cat <<'OEF'> /tmp/3.ldif
dn: cn=ORG.EXAMPLE.LOCAL,cn=krbContainer,dc=org,dc=example,dc=local
objectClass: top
objectClass: krbRealmContainer
cn: ORG.EXAMPLE.LOCAL
OEF
#ldapadd -x -D cn=admin,dc=org,dc=example,dc=local  -w admin_password -f /tmp/3.ldif

```


UI login ldapadmin

```yaml
cn=admin,dc=org,dc=example,dc=local
admin_password
```


