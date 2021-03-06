## HazelCast Jet and IMDG with mySQL Source w/ CDC updates via Kafka-Connect Debezium connector for a scenario with batch and real time updates of securities data in mySQL 

In this example we want to test out both real time and batch feeds to IMDG and the write-thru' and read thru' capabilities for Hazelcast IMDG and the data pipelining via Hazelcast Jet working against an RDBMS SOR. The RDBMS can be updated by many apps and we want to demonstrate CDC capabilities via Kafka using Debezium CDC MySQL connectors to refresh the IMDG asynchronoulsy and also synchronously via a client app.
 
 


Setup is with docker-compose with 7 containers:
 
    1 Lenses.io container having single node Kafka/Schema registry/kafka-connect/Kafka REST server + Kafka Management UI
   
    2 Hazelcast Jet/IMDG cluster node containers (hazelcast1, hazelcast2)
    
    1 Hazelcast Jet/IMDG container used for submitting jet jobs (hz_jet_submit) 
   
    1 Hazelcast IMDG management center container (mancenter)
    
    1 Hazelcast Jet Management center (hz_jet_mancenter)
   
    1 Mysql source (SOR) DB container (mysql) - this will be our SOR for the demo
 
 
Use docker-compose to fire up all the above containers:

```
docker-compose -f hazelcast-jet-ent-docker-compose.yaml up -d
```
  

We get real-time and historic stock market data from Alphavantage Inc. APIs for daily OHLCV (open/high/low/close/volume) for the past 20 years (1999-2019) for 30 stocks in Dow Jones Industrial Average as well as real time data in 1 minute increments for the same stocks over a 7 day window.

MySQL container has folder  /scripts for data loading which create a securiries_master database and populate tables with stock data above as well as reference data on all S&P 500 stocks. In order to help with editing/debugging of DB scripts without having to respin the containers every time and to persist data locally on host, mysql scripts, conf, and data folders are mapped to a host volume via docker-compose. 

To run the data loading scripts inside the container:

  ```
  hazelcast-kafka-cdc-test $ docker exec -it mysql bash
  
  root@ee8690b41e43:/# /scripts/init-create-load-databases-tables.sh
  ```


Kafka container has a scripts folder with the configurations for Kafka-connect Debezium connector to mySQL to handle CDC updates from the mySQL source DB. To configure the Debezium connector go to lenses UI on kakfa container by navigating to: 

   http://localhost:3030 (username: admin, password: admin)

To configure kafka-connect mySQL debezium connector, navigate to Connectors -> Create New Connector -> Choose "CDC for MySQL" and copy and paste the properties (uncommented part of the file) from the file in the kafka-scripts/debezium-mysql-connector.properties into the UI. The connector should startup and create several topics (one for capturing database wide DDL events, one topic per table for update events for each table). In order to help with editing/debugging of scripts or config files without having to respin the containers every time and to persist data locally on host, scripst and config files are mapped to a host volume via docker-compose. 

Hazelcast management center is at: http://localhost:8080/hazelcast-mancenter/login.html Setup a login and verify that the cluster hz-jet-ent-cluster is operational with 3 Jet/IMDG nodes (running on ports 5701, 5702, 5703 of the host)

Hazelcast Jet management center is at: http://localhost:9090 Use default credentials (admin/admin) to login and and verify that the cluster hz-jet-ent-cluster is operational with 3 Jet/IMDG nodes (running on ports 5701, 5702, 5703 of the host)

There is also a test hazelcast jet job provided as a maven project in the kafka2imap folder tree in the repo. This will read the topic "sp500_stocks" and write to a Hazelcast IMap called "securities_,master.sp500_stocks". To build the shaded (fat) jar to submit this job to jet run mvn clean package on the provided pom.xml file in the kafka2imap project folder. This will create a jar with all dependencies included (note: In order to use the jet built in wrapper script to submit jobs from commandline to the ject/IMDG cluster we need to package all dependencies and submit them together or add the dependecies to classpath as part of job submission as there is no guarantee that dependencies will be available on all the nodes in the grid)
In order to help with editing/debugging of scripts or config files without having to re-spin the containers every time and to persist data locally on host there is a job-jars folder for job artifacts and a resources folder which has all the script and config files mapped to a host volume via docker-compose. 

To submit jobs to jet using the submit commandline utility, we have a convenience wrapper script that is run inside the hz_jet_submit container as follows:


   ```
   hazelcast-kafka-cdc-test $ docker exec -it hz_jet_submit bash
   
   bash-4.4# pwd
   
   /opt/hazelcast-jet-enterprise
   
   bash-4.4# cd job-jars/
   
   bash-4.4# ls
   
   kafka2imap-1.0-SNAPSHOT.jar  run-kafka2imap-job.sh        run-wordcount-job.sh         test.out
   
   bash-4.4# ./run-kafka2imap-job.sh
   
   Verbose mode is on, setting logging level to INFO
   
   Submitting JAR './job-jars/kafka2imap-1.0-SNAPSHOT.jar' with arguments []
   ```
  
  





   
