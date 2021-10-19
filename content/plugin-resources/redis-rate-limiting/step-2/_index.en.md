+++
title = "Set up rate-limiting plugin"
weight = 12
+++

#### Add rate-limiting plugin

Add the rate-limiting plugin with a global rate-limiting policy:

```bash
echo '
apiVersion: configuration.konghq.com/v1
kind: KongClusterPlugin
metadata:
  name: global-rate-limit
  annotations:
    kubernetes.io/ingress.class: kong
  labels:
    global: "true"
config:
  minute: 5
  policy: local
plugin: rate-limiting
' | kubectl apply -f -
```

**Response**

```
kongplugin.configuration.konghq.com/global-rate-limit created
```

### Results
Here you configure Kong for Kubernetes to rate-limit traffic from any client to 5 requests per minute, applying this policy in a global sense. This means the rate-limit will apply across all services.

**Note:** You can set this up for a specific Ingress or a specific service as well, please follow using KongPlugin resource guide on steps for doing that.


#### Verify traffic control
Next, test the rate-limiting policy by executing the following command multiple times and observe the rate-limit headers in the response, specially, `X-RateLimit-Remaining-Minute`,`RateLimit-Reset`, and `Retry-After` :

```bash
curl -I $DATA_PLANE_LB/foo-redis/headers
```

**Response**

```
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 384
Connection: keep-alive
RateLimit-Limit: 5
RateLimit-Remaining: 0
X-RateLimit-Remaining-Minute: 0
RateLimit-Reset: 53
X-RateLimit-Limit-Minute: 5
Server: gunicorn/19.9.0
Date: Tue, 19 Oct 2021 19:51:07 GMT
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
X-Kong-Upstream-Latency: 1
X-Kong-Proxy-Latency: 1
Via: kong/2.6.0.0-enterprise-edition
```

After sending too many requests,once the rate limiting is reached, you will see `HTTP/1.1 429 Too Many Requests`

```bash
HTTP/1.1 429 Too Many Requests
Date: Tue, 19 Oct 2021 19:51:37 GMT
Content-Type: application/json; charset=utf-8
Connection: keep-alive
RateLimit-Limit: 5
RateLimit-Remaining: 0
X-RateLimit-Remaining-Minute: 0
RateLimit-Reset: 23
X-RateLimit-Limit-Minute: 5
Retry-After: 23
Content-Length: 41
X-Kong-Response-Latency: 1
Server: kong/2.6.0.0-enterprise-edition
```

### Results
As there is a single Kong instance running, Kong correctly imposes the rate-limit and you can make only 5 requests in a minute.