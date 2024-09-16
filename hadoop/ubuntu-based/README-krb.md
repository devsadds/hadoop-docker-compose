# Kerberos

##  Проверка соединения с ldap server

```sh
ldapsearch -x -H ldap://omsk.linux2be.com:389 -D "cn=admin,dc=omsk,dc=linux2be,dc=com" -w admin_password
ldapsearch -x -H ldap://openldap:389 -b "dc=omsk,dc=linux2be,dc=com" "(cn=krbContainer)" -w admin_password
```

нужно инициализировать базу данных Kerberos с помощью kdb5_ldap_util

```sh
cd /var/lib/krb5kdc
kdb5_ldap_util -D cn=admin,dc=omsk,dc=linux2be,dc=com destroy -r OMSK.LINUX2BE.COM
kdb5_ldap_util -D cn=admin,dc=omsk,dc=linux2be,dc=com create -subtrees dc=omsk,dc=linux2be,dc=com -r OMSK.LINUX2BE.COM -s
```


Потом

```sh
rm /etc/krb5kdc/openldappassword.keyfile
#или
kdb5_ldap_util stashsrvpw -f /etc/krb5kdc/openldappassword.keyfile cn=admin,dc=omsk,dc=linux2be,dc=com
#или
#kdb5_ldap_util -D "cn=admin,dc=omsk,dc=linux2be,dc=com" stashsrvpw -f /etc/krb5kdc/openldappassword.keyfile cn=admin,dc=omsk,dc=linux2be,dc=com

```
## Пользователи


```sh
kadmin.local -q "addprinc -randkey hive/odin-ha.omsk.linux2be.com@OMSK.LINUX2BE.COM"
kadmin.local -q "addprinc -randkey nn/odin-ha.omsk.linux2be.com@OMSK.LINUX2BE.COM"
kadmin.local -q "addprinc -randkey dn/odin-ha.omsk.linux2be.com@OMSK.LINUX2BE.COM"
kadmin.local -q "addprinc -randkey rm/odin-ha.omsk.linux2be.com@OMSK.LINUX2BE.COM"
kadmin.local -q "addprinc -randkey nm/odin-ha.omsk.linux2be.com@OMSK.LINUX2BE.COM"
kadmin.local -q "addprinc -randkey mapred/odin-ha.omsk.linux2be.com@OMSK.LINUX2BE.COM"
kadmin.local -q "addprinc -randkey sa0000mmprod@OMSK.LINUX2BE.COM"
kadmin.local -q "addprinc -randkey sa0000mmprod/odin-ha.omsk.linux2be.com@OMSK.LINUX2BE.COM"
```


## Keytabs

После создания принципалов, создайте keytab-файлы для каждого из них:
cd /opt/keytabs

kadmin.local -q "ktadd -k hive.keytab hive/odin-ha.omsk.linux2be.com@OMSK.LINUX2BE.COM
kadmin.local -q "ktadd -k nn.keytab nn/odin-ha.omsk.linux2be.com@OMSK.LINUX2BE.COM"
kadmin.local -q "ktadd -k dn.keytab dn/odin-ha.omsk.linux2be.com@OMSK.LINUX2BE.COM"
kadmin.local -q "ktadd -k rm.keytab rm/odin-ha.omsk.linux2be.com@OMSK.LINUX2BE.COM"
kadmin.local -q "ktadd -k nm.keytab nm/odin-ha.omsk.linux2be.com@OMSK.LINUX2BE.COM"
kadmin.local -q "ktadd -k mapred.keytab mapred/odin-ha.omsk.linux2be.com@OMSK.LINUX2BE.COM"
kadmin.local -q "ktadd -k sa0000mmprod.keytab sa0000mmprod@OMSK.LINUX2BE.COM"
kadmin.local -q "ktadd -k sa0000mmprod-odin.keytab sa0000mmprod/odin-ha.omsk.linux2be.com@OMSK.LINUX2BE.COM"


## Проверка аутентификации 


kinit -kt /opt/keytabs/rm.keytab rm/odin-ha.omsk.linux2be.com@OMSK.LINUX2BE.COM