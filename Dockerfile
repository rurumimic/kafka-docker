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
