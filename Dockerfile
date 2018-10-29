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
