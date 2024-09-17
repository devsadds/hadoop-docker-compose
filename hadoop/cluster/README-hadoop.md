# Hadoop

Фиксим пермы

```sh
docker exec -ti -u 0 ubuntu-based-hive-server-1 bash -c "chown -R hadoop:hadoop /opt/keytabs/* -v"
```


## Подключение к hive


```sh
kinit -kt /opt/keytabs/nm.keytab nm/odin-ha.omsk.linux2be.com@OMSK.LINUX2BE.COM
klist

```



```sh

kadmin.local -q "addprinc -randkey sa0000mmprod@OMSK.LINUX2BE.COM"
kadmin.local -q "addprinc -randkey sa0000mmprod/odin-ha.omsk.linux2be.com@OMSK.LINUX2BE.COM"

kinit -kt /opt/keytabs/sa0000mmprod.keytab sa0000mmprod@OMSK.LINUX2BE.COM
klist




beeline -u "jdbc:hive2://hive-server:10000/default;principal=hive/odin-ha.omsk.linux2be.com@OMSK.LINUX2BE.COM"



beeline -u "jdbc:hive2://hive-server:10000/default;principal=hive/odin-ha.omsk.linux2be.com@OMSK.LINUX2BE.COM"

jdbc:hive2://hiveserver.test.com:10000/default;principal=hive/hiveserver.test.com@TEST.COM

```


kadmin.local -q "addprinc -randkey sa0000mmprod@OMSK.LINUX2BE.COM"
kadmin.local -q "addprinc -randkey sa0000mmprod/odin-ha.omsk.linux2be.com@OMSK.LINUX2BE.COM"