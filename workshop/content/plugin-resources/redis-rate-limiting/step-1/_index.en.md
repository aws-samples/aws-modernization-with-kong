+++
title = "Set up ingress rule for Redis"
weight = 11
+++


#### Create an Ingress rule to proxy the httpbin service.

Let's add an Ingress rule which proxies requests to /redis to the httpbin-2 service

```bash
echo '
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: demo-redis
  annotations:
    konghq.com/strip-path: "true"
    kubernetes.io/ingress.class: kong
spec:
  rules:
  - http:
      paths:
      - path: /foo-redis
        backend:
          serviceName: httpbin-2
          servicePort: 80
' | kubectl apply -f -
```

**Response**

```
ingress.extensions/demo-redis created
```


#### Verify ingress rule

Test access to the httpbin-2 service

```bash
curl -i $DATA_PLANE_LB/foo-redis/status/200
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
