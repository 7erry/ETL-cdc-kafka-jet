import com.hazelcast.core.IMap;
import com.hazelcast.jet.JetInstance;
import com.hazelcast.jet.Job;
import com.hazelcast.jet.kafka.KafkaSources;
import com.hazelcast.jet.pipeline.Pipeline;
import com.hazelcast.jet.pipeline.Sinks;
import com.hazelcast.jet.server.JetBootstrap;
import org.apache.kafka.common.serialization.*;
import org.apache.kafka.connect.json.JsonDeserializer;
import com.hazelcast.jet.Util;
import com.hazelcast.core.HazelcastJsonValue;
import java.util.Properties;

import static com.hazelcast.jet.pipeline.Pipeline.create;
import static java.util.concurrent.TimeUnit.NANOSECONDS;

/**
 * A sample which demonstrates how to consume items Kafka topic with standard JSON
 * serialization into an IMap with same name
 */
public class Kafka2IMapJson {

    private static final String BROKER_HOST = "kafka";
    private static final String BROKER_PORT = "9092";
    private static final String AUTO_OFFSET_RESET = "earliest";
    private static final String TOPIC = "sp500_stocks";
    private static final String SINK_MAP_NAME = "securities_master.sp500_stocks";


    private static Pipeline buildPipeline() {
        System.out.println("Starting Pipeline");

	Properties properties = new Properties();
        properties.setProperty("group.id", "jet-cdc-demo");
        properties.setProperty("bootstrap.servers", BROKER_HOST + ':' + BROKER_PORT);
        properties.setProperty("key.deserializer", JsonDeserializer.class.getCanonicalName());
        properties.setProperty("value.deserializer", JsonDeserializer.class.getCanonicalName());
        properties.setProperty("auto.offset.reset", "earliest");

        Pipeline p = Pipeline.create();
        p.drawFrom(KafkaSources.kafka(properties, record -> {
            HazelcastJsonValue key = new HazelcastJsonValue(record.key().toString());
            HazelcastJsonValue value = new HazelcastJsonValue(record.value().toString());
            return Util.entry(key, value);
        }, TOPIC))
                .withoutTimestamps()
                .peek()
                .drainTo(Sinks.map(SINK_MAP_NAME));
        return p;
    }

    public static void main(String[] args) throws Exception {
        new Kafka2IMapJson().go();
    }

    private void go() throws InterruptedException {


            JetInstance jet = JetBootstrap.getInstance();
            //long start = System.nanoTime();

            Job job = jet.newJob(buildPipeline());

    }




    private static Properties props(String... kvs) {
        final Properties props = new Properties();
        for (int i = 0; i < kvs.length; ) {
            props.setProperty(kvs[i++], kvs[i++]);
        }
        return props;
    }

}



