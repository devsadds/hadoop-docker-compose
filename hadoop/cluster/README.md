# Full stack

## 1. Prepare

```
make build_docker
docker-compose up -d openldap
docker-compose up -d phpldapadmin
```


## 2. Ldap config

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
Теперь надо решить проблему с index `mdb_equality_candidates: (krbPrincipalName) not indexed`


```sh
cat <<'OEF'> /tmp/9.1-kerberos.indexes.ldif
dn: olcDatabase={1}mdb,cn=config
changetype: modify
add: olcDbIndex
olcDbIndex: krbPrincipalName eq
-
add: olcDbIndex
olcDbIndex: ou eq
OEF
ldapadd -QY EXTERNAL -H ldapi:///  -D cn=admin,dc=org,dc=example,dc=local -w ${LDAP_ADMIN_PASSWORD} -f /tmp/9.1-kerberos.indexes.ldif
```

UI login ldapadmin perms


```yaml
cn=admin,dc=org,dc=example,dc=local
admin_password
```



## 3. Kerberos config



Запускаем контейнер с  переменной  `CONTAINER_DEBUG_ON: "true"`

```sh
export CONTAINER_DEBUG_ON="true"
docker-compose up -d krb5
```

Проверка соединения с ldap server из контейнера krb5

```sh
docker exec -ti cluster-krb5-1 bash
```

```sh
ldapsearch -x -H ldap://openldap:389 -D "cn=admin,dc=org,dc=example,dc=local" -w admin_password
ldapsearch -x -H ldap://openldap:389 -b "dc=org,dc=example,dc=local" "(cn=krbContainer)"
```

нужно инициализировать базу данных Kerberos с помощью kdb5_ldap_util

```sh
cd /var/lib/krb5kdc
kdb5_ldap_util -D cn=admin,dc=org,dc=example,dc=local create -subtrees dc=org,dc=example,dc=local -r ORG.EXAMPLE.LOCAL -s
```

Потом - тут вводим пароль как в ldap

```sh
kdb5_ldap_util stashsrvpw -f /var/lib/krb5kdc/openldappassword.keyfile cn=admin,dc=org,dc=example,dc=local
#или
#kdb5_ldap_util -D "cn=admin,dc=org,dc=example,dc=local" stashsrvpw -f /etc/krb5kdc/openldappassword.keyfile cn=admin,dc=org,dc=example,dc=local
exit
```

Перезапускаем контейнер без  переменной `CONTAINER_DEBUG_ON: "true"`

```sh
export CONTAINER_DEBUG_ON="false"
docker-compose up -d krb5
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
```sh
cd /opt/keytabs
kadmin.local -q "ktadd -k hive.keytab hive/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "ktadd -k nn.keytab nn/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "ktadd -k dn.keytab dn/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "ktadd -k rm.keytab rm/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "ktadd -k nm.keytab nm/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "ktadd -k mapred.keytab mapred/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "ktadd -k sa0000mmprod.keytab sa0000mmprod@ORG.EXAMPLE.LOCAL"
kadmin.local -q "ktadd -k sa0000mmprod-odin.keytab sa0000mmprod/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
```

```sh
chown -R 2002 /opt/keytabs
```

## Проверка аутентификации 

```sh
docker exec -ti cluster-krb-client-1 bash
```

```sh
kinit -kt /opt/keytabs/rm.keytab rm/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL
klist
```

## 4. Hadoop and hive

```sh


docker-compose up -d namenode
docker-compose up -d datanode
docker-compose up -d resourcemanager
docker-compose up -d nodemanager
docker-compose up -d hive-metastore
docker-compose up -d hive-server
```

Чтобы подключиться k hive server нужно пробросить туда определенные конфиги. Возьмем их из запущенного сервера hive

```sh
mkdir -p  /root/hive/conf
docker cp cluster-hive-server-1:/opt/hive/conf/hive-site.xml /root/hive/conf/
docker cp cluster-hive-server-1:/opt/hive/conf/hdfs-site.xml /root/hive/conf/
docker cp cluster-hive-server-1:/opt/hive/conf/core-site.xml /root/hive/conf/
docker cp cluster-hive-server-1:/opt/hive/conf/log4j.properties /root/hive/conf/log4j.properties
```

Теперь положим в нашего клиента

```sh
docker cp /root/hive/conf/hive-site.xml cluster-krb-client-1:/opt/hive/conf/
docker cp /root/hive/conf/hdfs-site.xml cluster-krb-client-1:/opt/hive/conf/
docker cp /root/hive/conf/core-site.xml cluster-krb-client-1:/opt/hive/conf/
docker cp /root/hive/conf/log4j.properties cluster-krb-client-1:/opt/hive/conf/
```

Зайдем в нашего клиента

```sh
docker exec -ti cluster-krb-client-1 bash
```

```sh
export HADOOP_CONF_DIR=/opt/hive/conf/
# запрашиваем Kerberos-билет для сервисного аккаунта nm/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL, используя ключи из файла /opt/keytabs/sa0000mmprod-odin.keytab
kinit -kt /opt/keytabs/sa0000mmprod-odin.keytab nm/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL
klist
# Подключаемся 
/opt/hive/bin/beeline -u "jdbc:hive2://hive-server:10000/default;principal=hive/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
```

Выполним скрипт 

```sql
DROP TABLE IF EXISTS my_test_table_3;
CREATE TABLE IF  not EXISTS  my_test_table_3 (
  id INT,
  name STRING,
  created_at TIMESTAMP
);
SHOW TABLES;
INSERT INTO my_test_table_3 (id, name, created_at) VALUES (3, 'Alice', CURRENT_TIMESTAMP),(4, 'Bob', CURRENT_TIMESTAMP);
SELECT * FROM my_test_table_3;
DESCRIBE my_test_table_3;
```

## Проблемы

1. AuthenticationFilter:240 - Unable to initialize FileSignerSecretProvider, falling back to use random secrets. Reason: Could not read signature secret file: /opt/app-user/hadoop-http-auth-signature-secret

Решение 

```sh
head -c 32 /dev/urandom | base64 > /opt/keytabs/hadoop-http-auth-signature-secret
```

hadoop.http.authentication.signature.secret.file=/opt/keytabs/hadoop-http-auth-signature-secret

docker-compose restart resourcemanager nodemanager