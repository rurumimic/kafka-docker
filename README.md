# kafka-docker

Default Kafka cluster with docker.

DockerHub: [rurumimic/kafka-docker](https://hub.docker.com/r/rurumimic/kafka-docker)

- [Kafka](#kafka)
- [Dockerfile](#dockerfile)
  - [Build](#build)
  - [Image](#image)
- [Benchmark](#benchmark)
  - [Case 1](#case-1)
- [Basic example](#basic-example)
  1. [도커 컨테이너 실행](도커-컨테이너-실행)
  1. [주키퍼 서버 실행](주키퍼-서버-실행)
  1. [카프카 서버 실행](카프카-서버-실행)
  1. [토픽 생성](토픽-생성)
  1. [메시지 보내기](메시지-보내기)
  1. [메시지 확인하기](메시지-확인하기)
- [Performence Help](#performence-help)
  - [kafka-producer-perf-test.sh](#kafka-producer-perf-testsh)
  - [kafka-consumer-perf-test.sh](#kafka-consumer-perf-testsh)

---

## Kafka

[Apache Kafka](https://kafka.apache.org) [Documentation](https://kafka.apache.org/documentation/)

---

## Dockerfile

```ruby
# openjdk on alpine linux
FROM openjdk:12-alpine

# need bash to use kafka's script
# use Naver mirror
# use wget. extract in `/kafka`
RUN apk add --no-cache bash \
 && wget -q http://mirror.navercorp.com/apache/kafka/2.0.0/kafka_2.12-2.0.0.tgz \
 && tar xzf kafka_2.12-2.0.0.tgz \
 && mv kafka_2.12-2.0.0 kafka \
 && rm kafka_2.12-2.0.0.tgz

# basic configurations
# in openjdk:12-alpine JAVA_HOME is /opt/openjdk-12
ENV KAFKA_HOME=/kafka \
    KAFKA_CONF_DIR=$KAFKA_HOME/config \
    PATH=${PATH}:${KAFKA_HOME}/bin

# start in `/kafka`
WORKDIR $KAFKA_HOME

# kafka's default port: 9092
EXPOSE 9092

# start bash
CMD /bin/bash
```

### Build

```bash
docker build -t kafka:1.0 .
```

### Image

```bash
docker images

REPOSITORY    TAG    IMAGE ID        CREATED               SIZE
kafka         1.0    5affaf140364    About a minute ago    388MB
```

---

## Benchmark

[Benchmarking Apache Kafka](https://engineering.linkedin.com/kafka/benchmarking-apache-kafka-2-million-writes-second-three-cheap-machines)  
[dongjinleekr/consumer.sh](https://gist.github.com/dongjinleekr/d24e3d0c7f92ac0f80c87218f1f5a02b)

기본적인 사용방법은 아래 [Basic example](#basic-example)를 참고한다.



### Case 1

**Single producer thread, no replication, no compression**

**토픽 생성**

```bash
bin/kafka-topics.sh --create \
--zookeeper localhost:2181 \
--replication-factor 1 \
--partitions 1 \
--topic benchmark-1-1-none
```

**producer 성능 테스트**

```bash
bin/kafka-producer-perf-test.sh --topic benchmark-1-1-none \
--num-records 300000 \
--record-size 100 \
--throughput 10000 \
--producer-props \
acks=1 \
bootstrap.servers=localhost:9092 \
buffer.memory=67108864 \
compression.type=none \
batch.size=8196
```

- --num-records: 생산할 메시지 수.  
- --throughput: messages/sec. 초당 메시지 처리량.

throughput을 1만으로 하고 num-records를 30만으로 테스트 해본다.

```bash
49982 records sent, 9992.4 records/sec (0.95 MB/sec), 84.4 ms avg latency, 567.0 max latency.
50210 records sent, 10034.0 records/sec (0.96 MB/sec), 2.0 ms avg latency, 78.0 max latency.
50070 records sent, 10010.0 records/sec (0.95 MB/sec), 1.7 ms avg latency, 40.0 max latency.
49930 records sent, 9982.0 records/sec (0.95 MB/sec), 0.8 ms avg latency, 14.0 max latency.
50090 records sent, 10000.0 records/sec (0.95 MB/sec), 0.9 ms avg latency, 22.0 max latency.
300000 records sent, 9965.453096 records/sec (0.95 MB/sec), 15.13 ms avg latency, 567.00 ms max latency, 1 ms 50th, 66 ms 95th, 349 ms 99th, 396 ms 99.9th.
```

1초당 9965개 정도의 메시지를 보냈다.  
평균 지연시간은 15.13 ms, 최대 지연시간은 567.00 ms다.  

**consumer 성능 테스트**

```bash
bin/kafka-consumer-perf-test.sh --topic benchmark-1-1-none \
--broker-list localhost:9092 \
--messages 300000 \
--threads 1 \
--hide-header \
--print-metrics
```

```bash
fetch-latency-avg           : 20.281
fetch-latency-max           : 53.000
records-consumed-rate       : 9552.923
records-consumed-total      : 300000.000
records-per-request-avg     : 9375.000
```

초당 9552개의 메시지를 처리했다.

---

## Basic example

[Quickstart](https://kafka.apache.org/documentation/#quickstart)

간단하게 카프카를 사용해보자.  

### 1. 도커 컨테이너 실행

먼저 컨테이너를 실행한다.

```bash
docker run --rm -it kafka:1.0

bash-4.4# pwd
/kafka
```

도커 컨테이너에 접속됐다.  

### 2. 주키퍼 서버 실행

카프카는 주키퍼가 필요하다.  
카프카에 내장되어 있는 주키퍼를 실행한다.

```bash
bin/zookeeper-server-start.sh config/zookeeper.properties &

[2018-10-26 22:07:07,593] INFO Reading configuration from: config/zookeeper.properties
... 생략

(엔터 한 방)
bash-4.4#
```

### 3. 카프카 서버 실행

카프카 서버를 실행한다.

```bash
bin/kafka-server-start.sh config/server.properties &

[2018-10-26 22:13:39,554] INFO Registered kafka:type=kafka.Log4jController MBean
... 생략

(엔터 한 방)
bash-4.4#
```

### 4. 토픽 생성

공식 문서에서는 "test"라는 토픽을 만든다.  
여기서는 "chat"이라는 토픽을 만들어보자.

```bash
bin/kafka-topics.sh --create \
--zookeeper localhost:2181 \
--replication-factor 1 \
--partitions 1 \
--topic chat

... 생략

(엔터 한 방)
bash-4.4#
```

옵션으로 주키퍼의 `IP:PORT`를 지정한다.  
`replication-factor(복제 수)`와 `partitions(파티션)`은 한 개로 한다.

토픽 목록을 확인한다.

```bash
bin/kafka-topics.sh --list --zookeeper localhost:2181

...
chat
...
```

### 5. 메시지 보내기

producer를 실행해서 메시지를 보내보자.  
한 줄을 입력할 때마다 메시지가 전송된다.

```bash
bin/kafka-console-producer.sh \
--broker-list localhost:9092 \
--topic chat

>Hello there.
>May the force be with you.
>

# Ctl + C로 종료
```

### 6. 메시지 확인하기

consumer를 실행하면 메시지를 확인할 수 있다.

```bash
bin/kafka-console-consumer.sh \
--bootstrap-server localhost:9092 \
--topic chat \
--from-beginning

...
Hello there.
May the force be with you.

# Ctl + C로 종료
...
Processed a total of 2 messages
```

## Performence Help

### kafka-producer-perf-test.sh

```bash
usage: producer-performance [-h] --topic TOPIC --num-records NUM-RECORDS [--payload-delimiter PAYLOAD-DELIMITER] --throughput THROUGHPUT
                      [--producer-props PROP-NAME=PROP-VALUE [PROP-NAME=PROP-VALUE ...]] [--producer.config CONFIG-FILE] [--print-metrics]
                      [--transactional-id TRANSACTIONAL-ID] [--transaction-duration-ms TRANSACTION-DURATION] (--record-size RECORD-SIZE |
                      --payload-file PAYLOAD-FILE)

This tool is used to verify the producer performance.

optional arguments:
-h, --help             show this help message and exit
--topic TOPIC          produce messages to this topic
--num-records NUM-RECORDS
                   number of messages to produce
--payload-delimiter PAYLOAD-DELIMITER
                   provides delimiter to be used when --payload-file is provided. Defaults  to  new  line.  Note that this parameter will be ignored if --payload-
                   file is not provided. (default: \n)
--throughput THROUGHPUT
                   throttle maximum message throughput to *approximately* THROUGHPUT messages/sec
--producer-props PROP-NAME=PROP-VALUE [PROP-NAME=PROP-VALUE ...]
                   kafka producer related configuration properties like bootstrap.servers,client.id etc.  These  configs  take precedence over those passed via --
                   producer.config.
--producer.config CONFIG-FILE
                   producer config properties file.
--print-metrics        print out metrics at the end of the test. (default: false)
--transactional-id TRANSACTIONAL-ID
                   The transactionalId to use if transaction-duration-ms  is  >  0.  Useful  when  testing  the  performance of concurrent transactions. (default:
                   performance-producer-default-transactional-id)
--transaction-duration-ms TRANSACTION-DURATION
                   The max age of each transaction. The commitTransaction will be called after  this time has elapsed. Transactions are only enabled if this value
                   is positive. (default: 0)

either --record-size or --payload-file must be specified but not both.

--record-size RECORD-SIZE
                   message size in bytes. Note that you must provide exactly one of --record-size or --payload-file.
--payload-file PAYLOAD-FILE
                   file to read the message payloads from. This works only for UTF-8 encoded  text  files. Payloads will be read from this file and a payload will
                   be randomly selected when sending messages. Note that you must provide exactly one of --record-size or --payload-file.         
```

### kafka-consumer-perf-test.sh

```bash
Option                                   Description                            
------                                   -----------                            
--broker-list <String: host>             REQUIRED: The server(s) to connect to.
--consumer.config <String: config file>  Consumer config properties file.       
--date-format <String: date format>      The date format to use for formatting  
                                           the time field. See java.text.       
                                           SimpleDateFormat for options.        
                                           (default: yyyy-MM-dd HH:mm:ss:SSS)   
--fetch-size <Integer: size>             The amount of data to fetch in a       
                                           single request. (default: 1048576)   
--from-latest                            If the consumer does not already have  
                                           an established offset to consume     
                                           from, start with the latest message  
                                           present in the log rather than the   
                                           earliest message.                    
--group <String: gid>                    The group id to consume on. (default:  
                                           perf-consumer-18976)                 
--help                                   Print usage.                           
--hide-header                            If set, skips printing the header for  
                                           the stats                            
--messages <Long: count>                 REQUIRED: The number of messages to    
                                           send or consume                      
--num-fetch-threads <Integer: count>     Number of fetcher threads. (default: 1)
--print-metrics                          Print out the metrics.                 
--reporting-interval <Integer:           Interval in milliseconds at which to   
  interval_ms>                             print progress info. (default: 5000)
--show-detailed-stats                    If set, stats are reported for each    
                                           reporting interval as configured by  
                                           reporting-interval                   
--socket-buffer-size <Integer: size>     The size of the tcp RECV size.         
                                           (default: 2097152)                   
--threads <Integer: count>               Number of processing threads.          
                                           (default: 10)                        
--timeout [Long: milliseconds]           The maximum allowed time in            
                                           milliseconds between returned        
                                           records. (default: 10000)            
--topic <String: topic>                  REQUIRED: The topic to consume from.
```
