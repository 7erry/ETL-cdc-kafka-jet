FROM hazelcast/hazelcast-jet-enterprise
WORKDIR ${JET_HOME}
# Adding custom hazelcast.xml
COPY ./resources ${JET_HOME}/config-ext



#ENV HOST_IP 'ipconfig getifaddr en0' - does not work
#ENV JAVA_OPTS -Dhazelcast.config=${JET_HOME}/hazelcast.xml -Dhazelcast.mancenter.url=http://192.168.1.22:8080/hazelcast-mancenter -Dgroup.name=new-hz-cluster -Dgroup.password=s3cr3t