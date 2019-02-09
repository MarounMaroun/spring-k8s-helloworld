FROM gradle:jdk10 as builder

COPY --chown=gradle:gradle . /app
WORKDIR /app
RUN gradle build

EXPOSE 8080
WORKDIR /app

CMD java -jar build/libs/gs-spring-boot-0.1.0.jar
