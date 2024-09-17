# Kerberos

##  Проверка соединения с ldap server

```sh
ldapsearch -x -H ldap://openldap:389 -D "cn=admin,dc=org,dc=example,dc=local" -w admin_password
ldapsearch -x -H ldap://openldap:389 -b "dc=org,dc=example,dc=local" "(cn=krbContainer)" -w admin_password
```

нужно инициализировать базу данных Kerberos с помощью kdb5_ldap_util

```sh
cd /var/lib/krb5kdc
kdb5_ldap_util -D cn=admin,dc=org,dc=example,dc=local destroy -r ORG.EXAMPLE.LOCAL
kdb5_ldap_util -D cn=admin,dc=org,dc=example,dc=local create -subtrees dc=org,dc=example,dc=local -r ORG.EXAMPLE.LOCAL -s
```


Потом

```sh
rm /etc/krb5kdc/openldappassword.keyfile
#или
kdb5_ldap_util stashsrvpw -f /etc/krb5kdc/openldappassword.keyfile cn=admin,dc=org,dc=example,dc=local
#или
#kdb5_ldap_util -D "cn=admin,dc=org,dc=example,dc=local" stashsrvpw -f /etc/krb5kdc/openldappassword.keyfile cn=admin,dc=org,dc=example,dc=local

```
## Пользователи


```sh
kadmin.local -q "addprinc -randkey hive/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "addprinc -randkey nn/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "addprinc -randkey dn/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "addprinc -randkey rm/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "addprinc -randkey nm/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "addprinc -randkey mapred/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "addprinc -randkey sa0000mmprod@ORG.EXAMPLE.LOCAL"
kadmin.local -q "addprinc -randkey sa0000mmprod/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
```


## Keytabs

После создания принципалов, создайте keytab-файлы для каждого из них:
cd /opt/keytabs

kadmin.local -q "ktadd -k hive.keytab hive/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL
kadmin.local -q "ktadd -k nn.keytab nn/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "ktadd -k dn.keytab dn/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "ktadd -k rm.keytab rm/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "ktadd -k nm.keytab nm/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "ktadd -k mapred.keytab mapred/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "ktadd -k sa0000mmprod.keytab sa0000mmprod@ORG.EXAMPLE.LOCAL"
kadmin.local -q "ktadd -k sa0000mmprod-odin.keytab sa0000mmprod/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"


## Проверка аутентификации 


kinit -kt /opt/keytabs/rm.keytab rm/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL