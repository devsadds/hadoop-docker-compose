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
kadmin.local -q "addprinc -randkey hdfs/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "addprinc -randkey hive/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "addprinc -randkey nn/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "addprinc -randkey dn/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "addprinc -randkey rm/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "addprinc -randkey nm/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "addprinc -randkey mapred/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "addprinc -randkey timeline/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "addprinc -randkey hh/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "addprinc -randkey sa0000mmprod@ORG.EXAMPLE.LOCAL"
kadmin.local -q "addprinc -randkey sa0000mmprod/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"

kadmin.local -q "addprinc -randkey hdfs@ORG.EXAMPLE.LOCAL"

```


## Keytabs

После создания принципалов, создайте keytab-файлы для каждого из них:
```sh
cd /opt/keytabs
kadmin.local -q "ktadd -k hdfs.keytab hdfs/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "ktadd -k hive.keytab hive/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "ktadd -k nn.keytab nn/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "ktadd -k dn.keytab dn/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "ktadd -k rm.keytab rm/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "ktadd -k nm.keytab nm/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "ktadd -k mapred.keytab mapred/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "ktadd -k timeline.keytab timeline/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "ktadd -k hh.keytab hh/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"
kadmin.local -q "ktadd -k sa0000mmprod.keytab sa0000mmprod@ORG.EXAMPLE.LOCAL"
kadmin.local -q "ktadd -k sa0000mmprod-odin.keytab sa0000mmprod/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL"

```
При создании увидим подобные сообщения

```sh
Entry for principal hdfs@ORG.EXAMPLE.LOCAL with kvno 2, encryption type aes256-cts-hmac-sha1-96 added to keytab WRFILE:hdfs.keytab.
Entry for principal hdfs@ORG.EXAMPLE.LOCAL with kvno 2, encryption type aes128-cts-hmac-sha1-96 added to keytab WRFILE:hdfs.keytab.
```

Создадим hadoop.http.authentication.signature.secret.file
```sh
head -c 32 /dev/urandom | base64 > /opt/keytabs/hadoop-http-auth-signature-secret
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
docker exec -ti -u 0 cluster-krb-client-1 sh -c 'chown -R 2002 /opt/hive/conf'
```

Зайдем в нашего клиента

```sh
docker exec -ti cluster-krb-client-1 bash
```
```sh
cat<<'OEF'> /opt/hive/conf/log4j.properties
# Set the default logging level for all loggers to INFO
log4j.rootLogger=INFO, A1

# Define the console appender
log4j.appender.A1=org.apache.log4j.ConsoleAppender
log4j.appender.A1.target=System.err
log4j.appender.A1.layout=org.apache.log4j.PatternLayout
log4j.appender.A1.layout.ConversionPattern=%d{ISO8601} %p %c: %m%n

# Set the logging level for specific packages
log4j.logger.org.apache.hadoop=INFO
log4j.logger.org.apache.hive=INFO
OEF
```


```sh
# запрашиваем Kerberos-билет для сервисного аккаунта nm/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL, используя ключи из файла /opt/keytabs/sa0000mmprod-odin.keytab
kinit -kt /opt/keytabs/sa0000mmprod.keytab sa0000mmprod@ORG.EXAMPLE.LOCAL
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
INSERT INTO my_test_table_3 (id, name, created_at) VALUES (1, 'vasya', CURRENT_TIMESTAMP),(2, 'borya', CURRENT_TIMESTAMP);
INSERT INTO my_test_table_3 (id, name, created_at) VALUES (3, 'Alice', CURRENT_TIMESTAMP),(4, 'Bob', CURRENT_TIMESTAMP);
SELECT * FROM my_test_table_3;
DESCRIBE my_test_table_3;
```

Настойка datanode

```sh
docker exec -ti cluster-krb-client-1 bash
```

Сгенирим нужные сертификаты - без них датанода не работает в  kerberos режиме

```sh
# Создать keystore 
# !!Пароли ставим везеде admin_password!!
cd /opt/keytabs
# keystore с вашим ключом и самоподписанным сертификатом:
keytool -genkeypair -alias org.example.local -keyalg RSA -keysize 2048 -keystore keystore.jks -validity 1365
# Экспортируйте сертификат из keystore:
keytool -export -alias org.example.local -keystore keystore.jks -file org.example.local.crt
# Создайте truststore и импортируйте ранее экспортированный сертификат:
keytool -import -alias org.example.local -file org.example.local.crt -keystore truststore.jks -noprompt
chown -R 2002 /opt/keytabs
exit
```

Теперь запускаем datanode

```sh
docker-compose up datanode -d
```

Создадим директорий в hdfs

```sh
docker exec -it cluster-namenode-1 bash -c "kinit -kt /opt/keytabs/hdfs.keytab hdfs/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL;hdfs dfs -mkdir -p /user/hive/warehouse /tmp/hive /user/hadoop/.sparkStaging /spark-jars /spark-logs"
docker exec -it cluster-namenode-1 bash -c "kinit -kt /opt/keytabs/hdfs.keytab hdfs/odin-ha.org.example.local@ORG.EXAMPLE.LOCAL;hdfs dfs -put /opt/spark/jars/* /spark-jars"
```

Запустим остатки

```sh
docker-compose up -d
```

## Mans

HADOOP_SECURE - https://hadoop.apache.org/docs/stable/hadoop-mapreduce-client/hadoop-mapreduce-client-core/EncryptedShuffle.html