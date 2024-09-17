all: hadoop_first_start
prepre: create_dirs
build_docker: build_ubuntu build_openldap build_krb build_postgresql build_hadoop
hadoop_first_start:
	docker-compose up -d hive-metastore-postgresql; sleep 5; docker-compose up -d hive-metastore-init
	docker-compose up -d
	sleep 15;
	
testhive:
	docker exec -it cluster-hive-server-1 bash -c "/opt/hive/bin/beeline -u jdbc:hive2://hive-server:10000 -f /tmp/test/script.sql"

connect:
	docker exec -it cluster-hive-server-1 bash -c "/opt/hive/bin/beeline -u jdbc:hive2://127.0.0.1:10000"
testspark:
	docker exec -it cluster-spark-master-1 bash -c "spark-submit --master yarn --deploy-mode cluster --class org.apache.spark.examples.SparkPi /opt/spark/examples/jars/spark-examples_2.12-3.5.2.jar"

build_ubuntu:
	cd docker/ubuntu-jammy/ && make all
	cd ../..

build_krb:
	cd docker/krb5/ && make all
	cd ../..

build_hadoop:
	cd docker/hadoop-3.3.5-ubuntu/ && make all
	cd ../..

build_openldap:
	cd docker/openldap/ && make all
	cd ../..

build_postgresql:
	cd docker/postgresql/ && make all
	cd ../..


clean:
	docker-compose down -v

clean_kerberos:
	docker rm -f cluster-krb5-1
	docker volume rm cluster_krb5kdc_database_1
	docker-compose up -d krb5

create_dirs:
	mkdir -p logs/krb5 -m 777