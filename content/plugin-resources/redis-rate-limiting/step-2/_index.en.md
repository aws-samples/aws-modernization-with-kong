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
Next, test the rate-limiting policy by executing the following command multiple times and observe the rate-limit headers in the response:

```bash
curl -I $DATA_PLANE_LB/foo-redis/headers
```

**Response**

```
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 180
Connection: keep-alive
Server: gunicorn/19.9.0
Date:
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
X-RateLimit-Remaining-Minute: 2
X-RateLimit-Limit-Minute: 5
RateLimit-Remaining: 2
RateLimit-Limit: 5
RateLimit-Reset: 34
X-Kong-Upstream-Latency: 2
X-Kong-Proxy-Latency: 0
Via: kong/2.x
```

### Results
As there is a single Kong instance running, Kong correctly imposes the rate-limit and you can make only 5 requests in a minute.