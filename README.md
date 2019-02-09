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

Tha [YAML](https://github.com/MarounMaroun/spring-k8s-helloworld/blob/master/k8s/depl.yaml) file contains two resources: a **deployment** and a **service**:

```bash
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: hello-world
spec:
  replicas: 2
  template:
    metadata:
      labels:
        app: hello-world
        visualize: "true"
    spec:
      containers:
      - name: hello-world-pod
        image: marounbassam/hello-spring
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  labels:
    visualize: "true"
  name: hello-world-service
spec:
  selector:
    app: hello-world
  ports:
  - name: http
    protocol: TCP
    port: 8080
    targetPort: 8080
  type: ClusterIP

```

The deployment defines two replicas of the pod that will be running the container that's built from the image specified in the `image` attribute.

The service is of type **ClusterIP** (the default Kubernetes service). It gives us a service inside our cluster that other apps can access.

Creating the resources in your cluster:

```bash
kubectl create -f <yaml_file>
```

The resources can be visualized as follows:

```
+---------------------+
| hello-world-service |
|                     |
|    10.15.242.210    |
+---------O-----------+
          |
          +-------------O--------------------------O
                        |                          |
              +---------O-----------+    +---------O-----------+
              |        pod 1        |    |        pod 2        |
              |                     |    |                     |
              |     hello-world     |    |     hello-world     |
              +---------------------+    +---------------------+
```

### Inside The Cluster

If you're using *minikube* for running the cluster locally, you might encounter issues (I really don't know why). But if you're running on a cloud provider, or something more "serious" than minikube, you should be able to do the following:

```bash
$ kubectl get pods
NAME                         READY     STATUS    RESTARTS   AGE
hello-world-5bb87c95-6h4kh   1/1       Running   0          7h
hello-world-5bb87c95-bz64v   1/1       Running   0          7h
$ kubectl get svc
NAME                  TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
hello-world-service   ClusterIP   10.15.242.210   <none>        8080/TCP   5s
kubernetes            ClusterIP   10.15.240.1     <none>        443/TCP    7h
$ kubectl exec -it hello-world-5bb87c95-6h4kh bash
$ (inside the pod) curl 10.15.242.210:8080
$ (inside the pod) Greetings from Spring Boot!
```