# Dockerized Hadoop, Spark, Hive, and Zeppelin
### Medium Article
https://medium.com/@bayuadiwibowo/deploying-a-big-data-ecosystem-dockerized-hadoop-spark-hive-and-zeppelin-654014069c82
### Cluster Operation
#### Start the Cluster

    hostname # docker compose up -d

#### Stop the Cluster

    hostname # docker compose down

### Access the UIs
Access all UIs using spawned firefox: http://localhost:5800/. All services uses default port, please find it from the respective documentation.


## Дополнения


namenode % wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.28/mysql-connector-java-8.0.28.jar
namenode % mv mysql-connector-java-8.0.28.jar /opt/hive/lib/


namenode % tar zxvf apache-hive-3.1.3-bin.tar.gz
namenode % mv apache-hive-3.1.3-bin /opt/hive

## Hadoop config

```sh
cat <<'OEF'> core-site.xml
<configuration>
    <property>
        <name>hadoop.security.authentication</name>
        <value>kerberos</value>
    </property>
    <property>
        <name>hadoop.security.authorization</name>
        <value>true</value>
    </property>
    <property>
        <name>hadoop.security.krb5.conf</name>
        <value>/etc/krb5.conf</value>
    </property>
</configuration>
OEF

cat <<'OEF'> hdfs-site.xml
<configuration>
    <property>
        <name>dfs.namenode.kerberos.principal</name>
        <value>hdfs/_HOST@EXAMPLE.COM</value>
    </property>
    <property>
        <name>dfs.datanode.kerberos.principal</name>
        <value>hdfs/_HOST@EXAMPLE.COM</value>
    </property>
    <property>
        <name>dfs.namenode.keytab.file</name>
        <value>/path/to/hdfs.keytab</value>
    </property>
    <property>
        <name>dfs.datanode.keytab.file</name>
        <value>/path/to/hdfs.keytab</value>
    </property>
</configuration>

OEF

cat <<'OEF'>yarn-site.xml
<configuration>
    <property>
        <name>yarn.resourcemanager.principal</name>
        <value>yarn/_HOST@EXAMPLE.COM</value>
    </property>
    <property>
        <name>yarn.nodemanager.principal</name>
        <value>yarn/_HOST@EXAMPLE.COM</value>
    </property>
    <property>
        <name>yarn.resourcemanager.keytab</name>
        <value>/path/to/yarn.keytab</value>
    </property>
    <property>
        <name>yarn.nodemanager.keytab</name>
        <value>/path/to/yarn.keytab</value>
    </property>
</configuration>
OEF


cat <<'OEF'>mapred-site.xml
<configuration>
    <property>
        <name>mapreduce.jobtracker.principal</name>
        <value>mapred/_HOST@EXAMPLE.COM</value>
    </property>
    <property>
        <name>mapreduce.jobtracker.keytab</name>
        <value>/path/to/mapred.keytab</value>
    </property>
</configuration>
OEF


```

## Spark conf

curl -LO https://archive.apache.org/dist/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3.tgz --no-check-certificate

## Hive conf

```sh

curl -LO https://dlcdn.apache.org/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz
```

```sql
CREATE DATABASE hive;
CREATE USER hiveuser WITH PASSWORD 'hivepassword';
GRANT ALL PRIVILEGES ON DATABASE hive TO hiveuser;
```


```sh
cat <<'OEF'> hive-site.xml
<configuration>
    <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:postgresql://postgres:5432/hive</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionDriverName</name>
        <value>org.postgresql.Driver</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionUserName</name>
        <value>postgres</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionPassword</name>
        <value>phahMMMddd999h7uutheePighMMMdsdsdss</value>
    </property>
</configuration>
OEF
```

### Urls

```yaml
Namenode UI: http://namenode:9870/

ResourceManager UI: http://resourcemanager:8088/
```

### Usage

Submit Sample Job


```sh
 docker exec -ti hadoop-namenode-1 /bin/bash
yarn jar share/hadoop/mapreduce/hadoop-mapreduce-examples-${HADOOP_VERSION:-3.3.5}.jar pi 10 15
```


### MANS

https://medium.com/@bayuadiwibowo/deploying-a-big-data-ecosystem-dockerized-hadoop-spark-hive-and-zeppelin-654014069c82

https://github.com/bbonnin/docker-hadoop-3 - docker-haddop-3