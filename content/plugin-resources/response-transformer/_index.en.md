+++
title = "Response-Transformer plugin"
weight = 12
+++

#### Introduction
The [Response-Transformer](https://docs.konghq.com/hub/kong-inc/response-transformer/) plugin modifies the upstream response (e.g. response from the server) before returning it to the client.

In this section, you will configure the Response-Transformer plugin on the ingress resource. Specifically, you will configure Kong to modify the echo-server header to include "demo: injected-by-kong" before responding to the client.

#### Create KongPlugin resource
Create a KongPlugin resource, by configuring Kong for Kubernetes to execute the Response-Transformer plugin whenever a request matching the ingress rule is processed.

```bash
echo '
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: add-response-header
config:
  add:
    headers:
    - "demo: injected-by-kong"
plugin: response-transformer
' | kubectl apply -f -
```

**Response**
```
kongplugin.configuration.konghq.com/global-rate-limit created
```

### Associate plugin with the ingress rule

Associate the Response-Transformer plugin with the ingress rule you created previously.

```bash
kubectl patch ingress demo -p '{"metadata":{"annotations":{"konghq.com/plugins":"add-response-header"}}}'
```

### Verify
Test to make sure Kong transforms the request to the echo server and httpbin server. 

**Request 1**
```bash
curl -I $DATA_PLANE_LB/bar
```

**Response**
```
HTTP/1.1 200 OK
Content-Type: text/plain; charset=UTF-8
Connection: keep-alive
Date:
Server: echoserver
X-RateLimit-Remaining-Minute: 4
X-RateLimit-Limit-Minute: 5
RateLimit-Remaining: 4
RateLimit-Limit: 5
RateLimit-Reset: 35
demo:  injected-by-kong
X-Kong-Upstream-Latency: 1
X-Kong-Proxy-Latency: 0
Via: kong/2.0.3
```


**Request 2**
```bash
curl -i $DATA_PLANE_LB/foo/status/200
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
demo:  injected-by-kong
X-Kong-Upstream-Latency: 1
X-Kong-Proxy-Latency: 1
Via: kong/2.x
```

#### Results

Notice in the response "demo:  injected-by-kong" in injected in the header. Kong modifies the response with the Response-Transformer plugin when the requests matches the ingress rule defined in the demo ingress resource.  


#### What happens if you send request to /baz?
Send a request to  /baz.

```bash
curl -I $DATA_PLANE_LB/baz
```

**Response**
```
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8
Content-Length: 9593
Connection: keep-alive
Server: gunicorn/19.9.0
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
X-Kong-Upstream-Latency: 4
X-Kong-Proxy-Latency: 1
Via: kong/2.x
```



#### Results
If you send a request httpbin service with path /baz,  the header is not injected by Kong since this endpoint was not configured for the Response-Transformer plugin



#### Conclusion

You have successfully setup a plugin which is executed only when a request matches a specific Ingress rule.

Specifically, you configured Kong to modify the echo-server header to include "demo: injected-by-kong" before responding to the client. 













