# Hello K8s Spring Boot

A very simple hello-world example on running a docker container that has a Spring Boot server, inside a Kubernetes cluster.

### The Spring Application

The main entry is the [App](https://github.com/MarounMaroun/spring-k8s-helloworld/blob/master/src/main/java/hello/App.java) class, that starts the Spring Boot server.

The [controller](https://github.com/MarounMaroun/spring-k8s-helloworld/blob/master/src/main/java/hello/HelloWorldCtrl.java) returns the string:

> Greetings from Spring Boot!

### Building The Docker Image

The `Dockerfile` is very simple and basic:

```bash
FROM gradle:jdk10 as builder

COPY --chown=gradle:gradle . /app
WORKDIR /app
RUN gradle build

EXPOSE 8080
WORKDIR /app

CMD java -jar build/libs/gs-spring-boot-0.1.0.jar
```

It uses Gradle in order to build the application, and the `CMD` instruction runs the JAR file.

I already did that, and pushed to my private Docker Hub (marounbassam/hello-spring).

### The K8s Deployment

Tha [YAML](https://github.com/MarounMaroun/spring-k8s-helloworld/blob/master/k8s/depl.yaml) file contains two resources: a deployment and a service.

