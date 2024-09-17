# Ldap


## Prepare

```sh
docker exec -ti openldap bash
```

```sh
mkdir -p ~/ldap/
cp /openldap/schemas/* ~/ldap/



cat <<'OEF'> 2.5-schema-ldif.sh
#!/bin/bash

SCHEMAD=~/ldap

tmpd=`mktemp -d`
pushd ${tmpd} >>/dev/null

echo '' > convert.dat

for schema in ${SCHEMAS} ; do
    echo include ${SCHEMAD}/${schema} >> convert.dat
done

slaptest -f convert.dat -F .

if [ $? -ne 0 ] ; then
    echo "slaptest conversion failed"
    exit 
fi

for schema in ${SCHEMAS} ; do
    fullpath=${SCHEMAD}/${schema}
    schema_name=`basename ${fullpath} .schema`
    schema_dir=`dirname ${fullpath}`
    ldif_file=${schema_name}.ldif

    find . -name *${schema_name}.ldif -exec mv '{}' ./${ldif_file} \;
    sed -i "/dn:/ c dn: cn=${schema_name},cn=schema,cn=config" ${ldif_file}
    sed -i "/cn:/ c cn: ${schema_name}" ${ldif_file}
    sed -i '/structuralObjectClass/ d' ${ldif_file}
    sed -i '/entryUUID/ d' ${ldif_file}
    sed -i '/creatorsName/ d' ${ldif_file}
    sed -i '/createTimestamp/ d' ${ldif_file}
    sed -i '/entryCSN/ d' ${ldif_file}
    sed -i '/modifiersName/ d' ${ldif_file}
    sed -i '/modifyTimestamp/ d' ${ldif_file}
    sed -i '/^ *$/d' ${ldif_file}

    mv ${ldif_file} ${schema_dir}
done

popd >>/dev/null
rm -rf $tmpd
OEF


chmod +x /tmp/2.5-schema-ldif.sh
cd ~/ldap/
SCHEMAS='kerberos.schema sudo.schema' /tmp/2.5-schema-ldif.sh
ls ~/ldap | egrep '(kerberos.ldif|sudo.ldif)'

mv ~/ldap/{kerberos.ldif,sudo.ldif} /etc/ldap/schema
chown openldap:openldap /etc/ldap/schema/{kerberos.ldif,sudo.ldif}
chmod 0644 /etc/ldap/schema/{kerberos.ldif,sudo.ldif}

cat <<'OEF'> /tmp/2.5-add-schemas.ldif
include: file:///etc/ldap/schema/kerberos.ldif
include: file:///etc/ldap/schema/sudo.ldif
OEF
ldapadd -QY EXTERNAL -H ldapi:/// -w admin_password  -f /tmp/2.5-add-schemas.ldif

```




## Create user in openldap

```sh
docker exec -ti openldap bash
```

```sh
cat <<'OEF'> /tmp/1.ldif
dn: ou=People,dc=omsk,dc=linux2be,dc=com
objectClass: organizationalUnit
ou: People

dn: cn=sa0000mmprod,ou=People,dc=omsk,dc=linux2be,dc=com
objectClass: person
objectClass: inetOrgPerson
sn: sa0000mmprod
cn: sa0000mmprod
mail: sa0000mmprod@omsk.linux2be.com
userpassword: sa0000mmprod
OEF
ldapadd -x -D cn=admin,dc=omsk,dc=linux2be,dc=com  -w admin_password -f /tmp/1.ldif

cat <<'OEF'> /tmp/2.ldif
dn: cn=krbContainer,dc=omsk,dc=linux2be,dc=com
objectClass: top
objectClass: krbContainer
cn: krbContainer
OEF
ldapadd -x -D cn=admin,dc=omsk,dc=linux2be,dc=com  -w admin_password -f /tmp/2.ldif


cat <<'OEF'> /tmp/3.ldif
dn: cn=OMSK.LINUX2BE.COM,cn=krbContainer,dc=omsk,dc=linux2be,dc=com
objectClass: top
objectClass: krbRealmContainer
cn: OMSK.LINUX2BE.COM
OEF
ldapadd -x -D cn=admin,dc=omsk,dc=linux2be,dc=com  -w admin_password -f /tmp/3.ldif


adding new entry "cn=krbContainer,dc=omsk,dc=linux2be,dc=com"
ldap_add: Invalid syntax (21)
	additional info: objectClass: value #1 invalid per syntax


```

