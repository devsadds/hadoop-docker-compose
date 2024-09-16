
FROM apache/hadoop:3.3.5 AS hadoop
FROM docker-registry.services.linux2be.com:443/bigdata/platform/docker-images/ubuntu-jammy:v1.0.0
USER root
RUN groupadd -g 2002 ${DOCKER_IMAGE_RUN_USER:-hadoop} \
    && useradd -u 2002 -r -g 2002 -d "/opt/${DOCKER_IMAGE_RUN_USER:-app-user}" -c "Default Application User" ${DOCKER_IMAGE_RUN_USER:-hadoop}\
    && chown -R  ${DOCKER_IMAGE_RUN_USER:-hadoop}:${DOCKER_IMAGE_RUN_USER:-hadoop} /opt && rm -rf /opt/hadoop

RUN echo 'export JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which javac)))))' > /etc/profile.d/hadoop_java.sh \
    && echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /etc/profile.d/hadoop_java.sh \
    && echo 'export JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which javac)))))' > /etc/profile.d/hadoop_java.sh \
    && echo 'export HADOOP_HOME=/opt/hadoop' >> /etc/profile.d/hadoop_java.sh \
    && echo 'export HADOOP_HDFS_HOME=$HADOOP_HOME' >> /etc/profile.d/hadoop_java.sh \
    && echo 'export HADOOP_MAPRED_HOME=$HADOOP_HOME' >> /etc/profile.d/hadoop_java.sh \
    && echo 'export YARN_HOME=$HADOOP_HOME' >> /etc/profile.d/hadoop_java.sh \
    && echo 'export HADOOP_COMMON_HOME=$HADOOP_HOME' >> /etc/profile.d/hadoop_java.sh \
    && echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native' >> /etc/profile.d/hadoop_java.sh \
    && echo 'export PATH=$PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin' >> /etc/profile.d/hadoop_java.sh

RUN mkdir -p /hadoop/hdfs/{namenode,datanode} \
    && chown -R  ${DOCKER_IMAGE_RUN_USER:-hadoop}:${DOCKER_IMAGE_RUN_USER:-hadoop} /hadoop

USER hadoop

# Hadoop install
ENV HADOOP_RELEASE="3.3.5"
RUN cd /tmp/ \
    && curl -LO https://www-eu.apache.org/dist/hadoop/common/hadoop-$HADOOP_RELEASE/hadoop-$HADOOP_RELEASE.tar.gz \
    && tar -xzvf hadoop-$HADOOP_RELEASE.tar.gz \
    && mv hadoop-3.3.5 /opt/hadoop \
    && rm -rf /tmp/hadoop-$HADOOP_RELEASE.tar.gz \
    && mv /opt/hadoop/etc /opt/hadoop/etc.origin


# Spart install
RUN cd /tmp/ \
    && curl -LO https://dlcdn.apache.org/spark/spark-3.5.2/spark-3.5.2-bin-hadoop3.tgz \
    && tar -zxvf spark-3.5.2-bin-hadoop3.tgz \
    && mv spark-3.5.2-bin-hadoop3 /opt/spark \
    && rm -rf /tmp/spark-3.5.2-bin-hadoop3.tgz

# Hive install
RUN cd /tmp/ \
    && curl -LO https://downloads.apache.org/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz \
    && tar -zxvf apache-hive-3.1.3-bin.tar.gz \
    && mv apache-hive-3.1.3-bin  /opt/hive \
    && rm -rf /tmp/apache-hive-3.1.3-bin.tar.gz

RUN curl -L https://repo1.maven.org/maven2/org/postgresql/postgresql/42.2.5/postgresql-42.2.5.jar -o /opt/hive/lib/postgresql-42.2.5.jar

USER root
RUN apt-get update \
    && apt-get install -y openjdk-8-jdk openjdk-8-jre  python3 sudo dumb-init  krb5-user libpam-krb5 libsasl2-modules-gssapi-mit -y
RUN java -version
USER hadoop
COPY --from=hadoop  --chown=hadoop:hadoop /opt/hadoop/etc /opt/hadoop/etc
COPY --from=hadoop  --chown=hadoop:hadoop /opt/krb5.conf /opt/krb5.conf
COPY --from=hadoop  --chown=hadoop:hadoop /opt/envtoconf.py /opt/envtoconf.py
COPY --from=hadoop  --chown=hadoop:hadoop /opt/starter.sh /opt/starter.sh
COPY --from=hadoop  --chown=hadoop:hadoop /opt/transformation.py /opt/transformation.py
COPY --from=hadoop  --chown=hadoop:hadoop /opt/byteman.jar /opt/byteman.jar

USER root
RUN mkdir -p /data/hdfs /opt/hadoop/yarn/local /opt/hadoop/yarn/logs /opt/hadoop/logs \
    && chown -Rv hadoop:hadoop /data /opt/hadoop/yarn/ /opt/hadoop/logs /opt/starter.sh
RUN echo 'hadoop ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
    && ln -sfr $(which dumb-init) /usr/local/bin/dumb-init \
    && ln -sfr $(which python3) /usr/bin/python
USER hadoop

# Установка переменных окружения
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/hadoop/bin"
ENV JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/"
ENV HADOOP_LOG_DIR="/opt/hadoop/logs"
ENV HADOOP_CONF_DIR="/opt/hadoop/etc/hadoop"

# Создание рабочей директории
WORKDIR /opt/hadoop

# Установка прав на выполнение скрипта
RUN chmod +x /opt/starter.sh

# Указание точки входа с использованием dumb-init
ENTRYPOINT ["/usr/local/bin/dumb-init", "--", "/opt/starter.sh"]

# Определение тома
VOLUME ["/data"]
