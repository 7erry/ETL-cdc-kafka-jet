import com.hazelcast.core.IMap;
import com.hazelcast.jet.JetInstance;
import com.hazelcast.jet.Job;
import com.hazelcast.jet.kafka.KafkaSources;
import com.hazelcast.jet.pipeline.Pipeline;
import com.hazelcast.jet.pipeline.Sinks;
import com.hazelcast.jet.server.JetBootstrap;
import org.apache.kafka.common.serialization.*;
import org.springframework.kafka.support.serializer.JsonDeserializer;

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
        Pipeline p = create();
        p.drawFrom(
                KafkaSources.kafka(props(
                "bootstrap.servers", BROKER_HOST + ':' + BROKER_PORT,
                "group.id", "0",
                "key.deserializer", JsonDeserializer.class.getName(),
                "value.deserializer", JsonDeserializer.class.getName(),
//                "key.deserializer", StringSerializer.class.getName(),
//                "value.deserializer", StringSerializer.class.getName(),
                "auto.offset.reset", AUTO_OFFSET_RESET), TOPIC)
                )
                .withoutTimestamps()
//                .peek()
                .drainTo(Sinks.logger());
//                .drainTo(Sinks.map(SINK_MAP_NAME));
        return p;
    }

    public static void main(String[] args) throws Exception {
//        System.setProperty("hazelcast.logging.type", "log4j");
        new Kafka2IMapJson().go();
    }

    private void go() throws InterruptedException {


            JetInstance jet = JetBootstrap.getInstance();
            long start = System.nanoTime();

            Job job = jet.newJob(buildPipeline());

//            IMap<String, Integer> sinkMap = jet.getMap(SINK_MAP_NAME);
//            int prevSize = 0;
//
//            while (true) {
//                int mapSize = sinkMap.size();
//                System.out.format("Received %d entries in %d milliseconds.%n",
//                        mapSize - prevSize, NANOSECONDS.toMillis(System.nanoTime() - start));
////                prevSize = mapSize;
////                start =
////                if (mapSize == 20) {
////                    SECONDS.sleep(1);
////                    cancel(job);
////                    break;
////                }
//                Thread.sleep(100);
//            }
    }




    private static Properties props(String... kvs) {
        final Properties props = new Properties();
        for (int i = 0; i < kvs.length; ) {
            props.setProperty(kvs[i++], kvs[i++]);
        }
        return props;
    }

}



