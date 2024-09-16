all: hadoop_first_start hadoop_init
hadoop_first_start:
	docker-compose up -d hive-metastore-postgresql; sleep 5; docker-compose up -d hive-metastore-init
	docker-compose up -d
	sleep 15;

hadoop_init:
	docker exec -ti -u 0 ubuntu-based-datanode-1 bash -c "chown -Rv hadoop:users /data/hdfs"

	docker exec -it ubuntu-based-namenode-1 bash -c "hdfs dfs -mkdir -p /user/hive/warehouse"
	docker exec -it ubuntu-based-namenode-1 bash -c "hdfs dfs -mkdir -p /tmp/hive"
	docker exec -it ubuntu-based-namenode-1 bash -c "hdfs dfs -chmod 777 /tmp/"
	docker exec -it ubuntu-based-namenode-1 bash -c "hdfs dfs -chmod 777 /user/hive/warehouse"
	docker exec -it ubuntu-based-namenode-1 bash -c "hdfs dfs -chmod 777 /tmp/hive"
	docker exec -ti ubuntu-based-namenode-1 bash -c "hdfs dfs -ls /user/hive/warehouse"
	docker exec -it ubuntu-based-namenode-1 bash -c "hdfs dfs -mkdir -p /user/spark/jars"
	docker exec -it ubuntu-based-namenode-1 bash -c "hdfs dfs -mkdir -p /user/spark/spark-events"
	docker exec -it ubuntu-based-namenode-1 bash -c "hdfs dfs -mkdir -p /user/hadoop/.sparkStaging"
	#docker exec -it ubuntu-based-namenode-1 bash -c "hdfs dfs -put /opt/spark/jars/* /user/spark/jars/"
	docker exec -ti ubuntu-based-namenode-1 bash -c "hdfs dfs -ls /user/spark/jars/"
	sleep 5;
	docker-compose down hive-server; docker-compose up -d hive-server
	docker exec -ti ubuntu-based-namenode-1 bash -c "hdfs dfs -ls /user/hadoop/.sparkStaging"
	docker-compose stop spark-master;
	docker-compose stop spark-worker;
	docker-compose up -d ;
testhive:
	docker exec -it ubuntu-based-hive-server-1 bash -c "/opt/hive/bin/beeline -u jdbc:hive2://hive-server:10000 -f /tmp/test/script.sql"

connect:
	docker exec -it ubuntu-based-hive-server-1 bash -c "/opt/hive/bin/beeline -u jdbc:hive2://127.0.0.1:10000"
testspark:
	docker exec -it ubuntu-based-spark-master-1 bash -c "spark-submit --master yarn --deploy-mode cluster --class org.apache.spark.examples.SparkPi /opt/spark/examples/jars/spark-examples_2.12-3.5.2.jar"


build:
	cd docker/3.3.5-ubuntu/ && make all
	cd ../..

clean:
	docker-compose down -v