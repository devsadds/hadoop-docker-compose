all: hadoop_first_start hadoop_init
hadoop_first_start:
	docker-compose up -d hive-metastore-postgresql; sleep 5; docker-compose up -d hive-metastore-init
	docker-compose up -d
	sleep 10;

hadoop_init:
	docker exec -ti -u 0 hadoop-datanode-1 bash -c "chown -Rv hadoop:hadoop /data/hdfs"
	docker exec -it hadoop-namenode-1 bash -c "hdfs dfs -mkdir -p /user/hive/warehouse"
	docker exec -ti hadoop-datanode-1 bash -c "hdfs dfs -ls /user/hive/warehouse"
	docker exec -it hadoop-namenode-1 bash -c "hdfs dfs -mkdir -p /user/spark/jars"
	docker exec -it hadoop-namenode-1 bash -c "hdfs dfs -put /opt/spark/jars/* /user/spark/jars/"

	sleep 5;
	docker-compose down hive-server; docker-compose up -d hive-server

testhive:
	docker exec -it hadoop-hive-server-1 bash -c "/opt/hive/bin/beeline -u jdbc:hive2://hive-server:10000 -f /tmp/test/script.sql"

connect:
	docker exec -it hadoop-hive-server-1 bash -c "/opt/hive/bin/beeline -u jdbc:hive2://hive-server:10000"
testspark:
	docker exec -it hadoop-spark-master-1 bash -c "spark-submit --master yarn --deploy-mode cluster --class org.apache.spark.examples.SparkPi /opt/spark/examples/jars/spark-examples_2.12-3.5.2.jar"


clean:
	docker-compose down -v