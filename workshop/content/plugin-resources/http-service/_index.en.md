+++
title = "HTTP Redirects"
weight = 16
+++

This guide walks through how to configure Kong Ingress Controller  to redirect HTTP request to HTTPS so that all communication from the external world to your APIs and micro services is encrypted.

#### Add ingress resource for httpbin service

Add an Ingress rule to proxy requests  to /foo-redirect to the httpbin  service

```bash
echo '
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: demo-redirect
  annotations:
    konghq.com/strip-path: "true"
    kubernetes.io/ingress.class: kong
spec:
  rules:
  - http:
      paths:
      - path: /foo-redirect
        backend:
          serviceName: httpbin
          servicePort: 80
' | kubectl apply -f -
```

**Response**

```
ingress.extensions/demo-redirect created
```

**Verify**

Test the Ingress rule:

```bash
curl -i  $DATA_PLANE_LB/foo-redirect/status/200
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

#### Set up HTTPs redirect

Create a KongIngress resource which will enforce a policy on Kong to accept only HTTPS requests for the above Ingress rule and send back a redirect if the request matches the Ingress rule.

```bash
echo '
apiVersion: configuration.konghq.com/v1
kind: KongIngress
metadata:
    name: demo-redirect
route:
  protocols:
  - https
  https_redirect_status_code: 302
' | kubectl apply -f -
```


**Response**

```
kongingress.configuration.konghq.com/https-only created
```


#### Associate the KongIngress resource 

Associate the KongIngress resource with the Ingress resource you created for the service.

```bash
kubectl patch ingress demo-redirect -p '{"metadata":{"annotations":{"konghq.com/override":"https-only"}}}'
```

**Response**

```
ingress.extensions/demo patched
```

#### Test it

Make a plain-text HTTP request to Kong.  

```bash
curl $DATA_PLANE_LB/foo-redirect/headers -I
```

**Response**

```bash
HTTP/1.1 302 Moved Temporarily
Date: 
Content-Type: text/html
Content-Length: 167
Connection: keep-alive
Location: https://35.197.125.63/foo-redirect/headers
Server: kong/2.x
```

**Results**

The results is a redirect **- 302 Moved Temporarily -**  issued from Kong as expected.

The  **Location**  header will contain the URL you need to use for an HTTPS request. 

**Please note** that this URL will be different depending on your installation method. You can also grab the IP address of the load balance  fronting Kong and send a HTTPS request to test it.


#### Verify HTTPs access

Use **location** header to access the service via HTTPS.  
Remember to replace the **Location URL** with then one above. 

```bash
curl -k Location URL
```

**Response**

```

{
  "headers": {
    "Accept": "*/*",
    "Connection": "keep-alive",
    "Host": "35.197.125.63",
    "User-Agent": "curl/7.54.0",
    "X-Forwarded-Host": "35.197.125.63"
  }
}
```

#### Results
You can see that Kong correctly serves the request only on HTTPS protocol and redirects the user if plaint-text HTTP protocol is used. We had to use  `-k`  flag in cURL to skip certificate validation as the certificate served by Kong is a self-signed one. If you are serving this traffic via a domain that you control and have configured TLS properties for it, then the flag won't be necessary.