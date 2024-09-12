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


## Требования 

 - свободное место более 90 %

## Дополнения установка

```sh
curl -LO https://repo1.maven.org/maven2/org/postgresql/postgresql/42.2.5/postgresql-42.2.5.jar \
    && mv postgresql-42.2.5.jar /opt/hive/lib/
```


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


## Hadoop prepare

```sh
docker exec -it hadoop-namenode-1 bash
hdfs dfs -mkdir -p /user/hive/warehouse
hdfs dfs -ls /user/hive/warehouse
```


## Hive Prepare 

In hive-metastore
```sh
/opt/hive/bin/schematool -dbType postgres -initSchema
```




### Envs

export HADOOP_HOME=/opt/hadoop

### Urls

```yaml
Namenode UI: http://namenode:9870/

ResourceManager UI: http://resourcemanager:8088/
```

### Usage

**Test hadoop**


```sh
hdfs dfs -mkdir /test_dir
echo "Hello, Hadoop" | hdfs dfs -put - /test_dir/test_file.txt
hdfs dfs -cat /test_dir/test_file.txt
```

**Submit Sample Job**

```sh
echo "hadoop mapreduce example example" | hdfs dfs -put - /test_dir/input.txt
yarn jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.5.jar wordcount /test_dir/input.txt /test_dir/output
hdfs dfs -cat /test_dir/output/part-r-00000
```

```sh
 docker exec -ti hadoop-namenode-1 /bin/bash
yarn jar share/hadoop/mapreduce/hadoop-mapreduce-examples-${HADOOP_VERSION:-3.3.5}.jar pi 10 15
```

**Submit Spark Job as examples**

```sh
/opt/spark/bin/spark-submit \
--master yarn \
--deploy-mode cluster \
--class org.apache.spark.examples.SparkPi /opt/spark/examples/jars/spark-examples_2.12-3.5.0.jar
```

### MISC

Load data into Hive:

```sh
  $ docker-compose exec hive-server bash
  # /opt/hive/bin/beeline -u jdbc:hive2://127.0.0.1:10000
  > CREATE TABLE pokes (foo INT, bar STRING);
  > LOAD DATA LOCAL INPATH '/opt/hive/examples/files/kv1.txt' OVERWRITE INTO TABLE pokes;
```

Then query it from PrestoDB. You can get [presto.jar](https://prestosql.io/docs/current/installation/cli.html) from PrestoDB website:
```sh
  $ wget https://repo1.maven.org/maven2/io/prestosql/presto-cli/308/presto-cli-308-executable.jar
  $ mv presto-cli-308-executable.jar presto.jar
  $ chmod +x presto.jar
  $ ./presto.jar --server localhost:8080 --catalog hive --schema default
  presto

```json
          "Image": "hadoop:3.3.5-r1",
            "Volumes": {
                "/data": {}
            },
            "WorkingDir": "/opt/hadoop",
            "Entrypoint": [
                "/usr/local/bin/dumb-init",
                "--",
                "/opt/starter.sh"
            ],

```


####
```sql
create database mm_ods_sec1;
USE mm_ods_sec1;
CREATE TABLE my_test_tablesa0000mmprod (
  id INT,
  name STRING,
  created_at TIMESTAMP
);
SHOW TABLES;
INSERT INTO my_test_tablesa0000mmprod (id, name, created_at) VALUES (1, 'Alice', CURRENT_TIMESTAMP),(2, 'Bob', CURRENT_TIMESTAMP);
SELECT * FROM my_test_tablesa0000mmprod;
DESCRIBE my_test_tablesa0000mmprod;
DROP TABLE my_test_tablesa0000mmprod;
```
### MANS

https://medium.com/@bayuadiwibowo/deploying-a-big-data-ecosystem-dockerized-hadoop-spark-hive-and-zeppelin-654014069c82

https://github.com/bbonnin/docker-hadoop-3 - docker-haddop-3

https://github.com/Marcel-Jan/docker-hadoop-spark