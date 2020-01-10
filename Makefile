# docker-compose-hazelcast-jet makefile

# Environment Variables
CONTAINER_SERVER = hz_jet_1 
CONTAINER_CLIENT = hz_jet_submit
CONTAINER_MYSQL = mysql

#export JOB_JAR=./hazelcast-jet-ent-base-image/jet-job-jars/$(shell ls -tr *jar| tail -2)
export JOB_JAR=./hazelcast-jet-ent-base-image/jet-job-jars/kafka2imap-1.0-SNAPSHOT.jar

.PHONY: up

prep :
	echo  $(JOB_JAR) file will be submitted to the cluster....

pull :
	docker-compose -f hazelcast-jet-ent-docker-compose.yaml pull

up : prep pull
	docker-compose -f hazelcast-jet-ent-docker-compose.yaml up -d

down :
	docker-compose -f hazelcast-jet-ent-docker-compose.yaml down

restart :
	docker-compose -f hazelcast-jet-ent-docker-compose.yaml restart $(CONTAINER_CLIENT)  

connectDb :
	docker-compose -f hazelcast-jet-ent-docker-compose.yaml exec $(CONTAINER_MYSQL) mysql -umysqluser -pmysqlpw  inventory

tailDb :
	docker-compose -f hazelcast-jet-ent-docker-compose.yaml logs -f $(CONTAINER_MYSQL)

tailServer :
	docker-compose -f hazelcast-jet-ent-docker-compose.yaml logs -f $(CONTAINER_SERVER)

tailClient :
	docker-compose -f hazelcast-jet-ent-docker-compose.yaml logs -f $(CONTAINER_CLIENT)

