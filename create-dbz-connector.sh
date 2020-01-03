cat << EOF > MySqlDBZConnector.json
{
  "name": "MySqlDBZConnector",
  "config": {
    "connector.class": "io.debezium.connector.mysql.MySqlConnector",
    "tasks.max": "1",
    "database.hostname": "mysql",
    "database.port": "3306",
    "database.user": "cdc_user",
    "database.password": "cdc_passwd",
    "database.server.id": "1234",
    "database.allowPublicKeyRetrieval": "true",
    "database.useSSL": "false",
    "database.server.name": "stock_data_demo",
    "database.whitelist": "securities_master",
    "database.history.kafka.bootstrap.servers": "kafka:9092",
    "database.history.kafka.topic": "dbhistory.stock_data_demo",
    "include.schema.changes": "true",
    "connector.client.config.override.policy": "All",
    "consumer.override.auto.offset.reset": "earliest",
    "transforms": "unwrap,route",
    "#transforms.unwrap.type": "io.debezium.transforms.UnwrapFromEnvelope",
    "transforms.route.type": "org.apache.kafka.connect.transforms.RegexRouter",
    "transforms.route.regex": "([^.]+)\\.([^.]+)\\.([^.]+)",
    "transforms.route.replacement": "$3",
    "decimal.handling.mode": "double",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
    "key.converter": "org.apache.kafka.connect.json.JsonConverter",
    "value.converter.schemas.enable": "true",
    "key.converter.schemas.enable": "true",
    "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
    "transforms.unwrap.operation.header": "true",
    "transforms.unwrap.add.source.fields": "db, table, name, server_id"
  }
}
EOF
##curl -X POST -H "Content-Type: application/json" -H "Accept: application/json" -u "admin" -p "admin" -d @MySqlDBZConnector.json http://localhost:3030/api/proxy-connect/dev/connectors
#curl -i -X POST -H "Content-Type: application/json" -H "Accept: application/json" http://localhost:8083/connectors -d @MySqlDBZConnector.json

# Lenses API require auth which is in the form of a token - all subsequent ops have to send the token in header
token=$(curl -X POST -H "Content-Type: application/json"  http://localhost:3030/api/login -d '{ "user" : "admin", "password" : "admin"}')
echo "${token}"
#resp=$(curl -X GET -H  "Content-Type:application/json" -H "X-Kafka-Lenses-Token: ${token}" http://localhost:3030/api/proxy-connect/dev/connector-plugins)

curl -X POST -H "Content-Type: application/json" -H "Accept: application/json" -H  "X-Kafka-Lenses-Token: ${token}" -d @MySqlDBZConnector.json http://localhost:3030/api/proxy-connect/dev/connectors

#
#
## Create new Debezium mySQL connector
#curl -X POST -H "Accept:application/json" \
#    -H  "Content-Type:application/json" http://localhost:3030/api/proxy-connect/dev/connectors \
#    -H  "X-Kafka-Lenses-Token: ${token}"
    -d '{
      "name": "MySqlDBZConnector",
      "config": {
        "connector.class": "io.debezium.connector.mysql.MySqlConnector",
        "tasks.max": "1",
        "database.hostname": "mysql",
        "database.port": "3306",
        "database.user": "cdc_user",
        "database.password": "cdc_passwd",
        "database.server.id": "1234",
        "database.allowPublicKeyRetrieval": "true",
        "database.useSSL": "false",
        "database.server.name": "stock_data_demo",
        "database.whitelist": "securities_master",
        "database.history.kafka.bootstrap.servers": "kafka:9092",
        "database.history.kafka.topic": "dbhistory.stock_data_demo",
        "include.schema.changes": "true",
        "connector.client.config.override.policy": "All",
        "consumer.override.auto.offset.reset": "earliest",
        "transforms": "unwrap,route",
        "#transforms.unwrap.type": "io.debezium.transforms.UnwrapFromEnvelope",
        "transforms.route.type": "org.apache.kafka.connect.transforms.RegexRouter",
        "transforms.route.regex": "([^.]+)\\.([^.]+)\\.([^.]+)",
        "transforms.route.replacement": "$3",
        "decimal.handling.mode": "double",
        "value.converter": "org.apache.kafka.connect.json.JsonConverter",
        "key.converter": "org.apache.kafka.connect.json.JsonConverter",
        "value.converter.schemas.enable": "true",
        "key.converter.schemas.enable": "true",
        "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
        "transforms.unwrap.operation.header": "true",
        "transforms.unwrap.add.source.fields": "db, table, name, server_id"
      }
    }'

echo "${resp}"