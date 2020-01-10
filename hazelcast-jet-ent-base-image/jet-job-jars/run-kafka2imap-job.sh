cd $JET_HOME
# Nasty reflection bug https://github.com/hazelcast/hazelcast-jet/issues/1420
export CLASSPATH=$CLASSPATH:./job-jars/kafka2imap-1.0-SNAPSHOT.jar
./bin/jet.sh -f ./config-ext/hazelcast-client.xml -v submit ./job-jars/kafka2imap-1.0-SNAPSHOT.jar


