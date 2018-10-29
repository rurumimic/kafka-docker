# kafka-docker

Default Kafka cluster with docker.

- [Kafka](#kafka)
- [Dockerfile](#dockerfile)
  - [Build](#build)
  - [Image](#image)
- [Simple example](#simple-example)
  1. [도커 컨테이너 실행](도커-컨테이너-실행)
  1. [주키퍼 서버 실행](주키퍼-서버-실행)
  1. [카프카 서버 실행](카프카-서버-실행)
  1. [토픽 생성](토픽-생성)
  1. [메시지 보내기](메시지-보내기)
  1. [메시지 확인하기](메시지-확인하기)

---

## Kafka

[Apache Kafka](https://kafka.apache.org) [Documentation](https://kafka.apache.org/documentation/)

---

## Dockerfile

```ruby
# alpine linux 기반에 openjdk를 사용한다.
FROM openjdk:12-alpine

# kafka의 스크립트를 사용하려면 bash가 필요하다.
# kafka는 naver 미러에서 받는다.
# wget으로 받아 /kafka에 압축을 푼다.
RUN apk add --no-cache bash \
 && wget -q http://mirror.navercorp.com/apache/kafka/2.0.0/kafka_2.12-2.0.0.tgz \
 && tar xzf kafka_2.12-2.0.0.tgz \
 && mv kafka_2.12-2.0.0 kafka \
 && rm kafka_2.12-2.0.0.tgz

# 기본적인 환경설정.
# JAVA_HOME은 openjdk:12-alpine에서 /opt/openjdk-12로 설정되었다.
ENV KAFKA_HOME=/kafka \
    KAFKA_CONF_DIR=$KAFKA_HOME/config \
    PATH=${PATH}:${KAFKA_HOME}/bin

# 컨테이너에 접속했을 때 /kafka에서 시작한다.
WORKDIR $KAFKA_HOME

# kafka는 9092 포트를 기본으로 사용한다.
EXPOSE 9092

# 컨테이너를 사용하기 편하도록 bash로 실행한다.
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

## Simple example

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
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic chat

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
bin/kafka-console-producer.sh --broker-list localhost:9092 --topic chat

>Hello there.
>May the force be with you.
>

# Ctl + C로 종료
```

### 6. 메시지 확인하기

consumer를 실행하면 메시지를 확인할 수 있다.

```bash
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic chat --from-beginning

...
Hello there.
May the force be with you.

# Ctl + C로 종료
...
Processed a total of 2 messages
```
