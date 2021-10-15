+++
title = "Ingress Rule"
weight = 11
+++

Expose the echo and httpbin services outside the Kubernetes cluster by defining Ingress rules.

#### Add ingress resource for echo service
Add an Ingress resource which proxies requests to  /foo to the httpbin service and /bar to the echo service

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
      - path: /foo
        backend:
          serviceName: httpbin
          servicePort: 80
      - path: /bar
        backend:
          serviceName: echo
          servicePort: 80
' | kubectl apply -f -
```

**Response**

```
ingress.extensions/demo created
```


#### Verify endpoints
Test access to the http service and echo service

**Request**

```bash
curl -i $DATA_PLANE_LB/foo/status/200
```

**Response**
```bash
HTTP/1.1 200 OK
Content-Type: text/plain; charset=UTF-8
Transfer-Encoding: chunked
Content-Length: 0
Connection: keep-alive
Server: gunicorn/19.9.0
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
X-Kong-Upstream-Latency: 1
X-Kong-Proxy-Latency: 1
Via: kong/2.x
```

**Request**
```bash
curl -i $DATA_PLANE_LB/bar
```

**Response**

```
HTTP/1.1 200 OK
Content-Type: text/plain; charset=UTF-8
Transfer-Encoding: chunked
Connection: keep-alive
Server: echoserver
X-RateLimit-Limit-minute: 5
X-RateLimit-Remaining-minute: 4
X-Kong-Upstream-Latency: 1
X-Kong-Proxy-Latency: 1
Via: kong/2.x

Hostname: echo-758859bbfb-wbs54
Pod Information:
        node name:      node1
        pod name:       echo-758859bbfb-wbs54
        pod namespace:  default
        pod IP: 10.32.0.7

Server values:
        server_version=nginx: 1.12.2 - lua: 10010

Request Information:
        client_address=10.32.0.2
        method=GET
        real path=/
        query=
        request_version=1.1
        request_scheme=http
        request_uri=http://10.108.140.182:8080/

Request Headers:
        accept=*/*
        connection=keep-alive
        host=10.108.140.182
        user-agent=curl/7.29.0
        x-forwarded-for=10.32.0.1
        x-forwarded-host=10.108.140.182
        x-forwarded-port=8000
        x-forwarded-proto=http
        x-real-ip=10.32.0.1

Request Body:
        -no body in request-
```

#### Results

A response with  HTTP/1.1 200 OK proxied Via: kong/2.x for both requests indicates the ingress rule is configured.



#### Add ingress resource for httpbin service
Let's add an Ingress resource which proxies requests to  /baz to the httpbin service. 

We will use this path later.

```bash
echo '
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: demo-2
  annotations:
    konghq.com/strip-path: "true"
    kubernetes.io/ingress.class: kong
spec:
  rules:
  - http:
      paths:
      - path: /baz
        backend:
          serviceName: httpbin
          servicePort: 80
' | kubectl apply -f -
```

**Response**
```
ingress.extensions/demo-2 created
```