export SPARK_HOME=/opt/spark
#export SPARK_JARS=""
#for jar in $(ls -1 $SPARK_HOME/jars | grep -ve 'log4j'); do
#    export SPARK_JARS=$SPARK_JARS:$SPARK_HOME/jars/$jar
#done
#export HIVE_AUX_JARS_PATH=$SPARK_JARS

export SPARK_HOME=/opt/spark
export SPARK_JARS=""
for jar in `ls $SPARK_HOME/jars`; do
    export SPARK_JARS=$SPARK_JARS:$SPARK_HOME/jars/$jar
done
export HIVE_AUX_JARS_PATH=$SPARK_JARS