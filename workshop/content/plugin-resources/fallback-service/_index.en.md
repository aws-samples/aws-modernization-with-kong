+++
title = "Fallback service"
weight = 15
+++

In this learning lab,  you will learn how to setup a fallback service using Ingress resource. The fallback service will receive all requests that don't match against any of the defined Ingress rules. 

This can be useful for scenarios where you would like to return a 404 page to the end user if the user clicks on a dead link or inputs an incorrect URL.

#### Set up Ingress rule

Add ingress resource for echo  service
Add an Ingress resource which proxies requests to and /cafe to the echo service

```bash
echo '
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: demo
  annotations:
    konghq.com/strip-path: "true"
    kubernetes.io/ingress.class: kong
spec:
  rules:
  - http:
      paths:
      - path: /cafe
        backend:
          serviceName: echo
          servicePort: 80
' | kubectl apply -f -
```

**Response**

```
ingress.extensions/demo created
```

**Verify**

Test the Ingress rule:

```bash
curl -i $DATA_PLANE_LB/cafe/status/200
```

**Response**

```
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8
Content-Length: 0
Connection: keep-alive
Server: gunicorn/19.9.0
Date:
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
X-Kong-Upstream-Latency: 2
X-Kong-Proxy-Latency: 1
Via: kong/2.x
```


#### Create a fallback sample service.

Add a KongPlugin resource for the fallback service

```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fallback-svc
spec:
  replicas: 1
  selector:
    matchLabels:
      app: fallback-svc
  template:
    metadata:
      labels:
        app: fallback-svc
    spec:
      containers:
      - name: fallback-svc
        image: hashicorp/http-echo
        args:
        - "-text"
        - "This is not the path you are looking for. - Fallback service"
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: fallback-svc
  labels:
    app: fallback-svc
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 5678
    protocol: TCP
    name: http
  selector:
    app: fallback-svc
EOF
```

#### Create ingress rule

Set up an Ingress rule to make it the fallback service to send all requests to it that don't match any of our Ingress rules:

```bash
echo '
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: fallback
  annotations:
    kubernetes.io/ingress.class: kong
spec:
  backend:
    serviceName: fallback-svc
    servicePort: 80
' | kubectl apply -f -
```

**Response**

```
ingress.extensions/fallback created
```

#### Verify fallback service

Now send a request with a request property that doesn't match against any of the defined rules:

```bash
curl $DATA_PLANE_LB/random-path
```

**Response**

```
This is not the path you are looking for. - Fallback service
```

#### Conclusion
Since the request is not part of any defined rule, the fallback service responds with **'This is not the path you are looking for. - Fallback service'**. 
