+++
title = "Kong Data Plane"
weight = 13
+++

#### Create Kubernetes Secret for mTLS

Create the secret for the Data Plane using the same Digital Certicate and Private Key pair:

```bash
kubectl create secret tls kong-cluster-cert --cert=./cluster.crt --key=./cluster.key -n kong-dp
```

#### Install the Data Plane


```
helm install kong-dp kong/kong -n kong-dp \
--set ingressController.enabled=false \
--set image.repository=kong/kong-gateway \
--set image.tag=2.6.0.0-alpine \
--set env.database=off \
--set env.role=data_plane \
--set env.cluster_cert=/etc/secrets/kong-cluster-cert/tls.crt \
--set env.cluster_cert_key=/etc/secrets/kong-cluster-cert/tls.key \
--set env.lua_ssl_trusted_certificate=/etc/secrets/kong-cluster-cert/tls.crt \
--set env.cluster_control_plane=kong-kong-cluster.kong.svc.cluster.local:8005 \
--set env.cluster_telemetry_endpoint=kong-kong-clustertelemetry.kong.svc.cluster.local:8006 \
--set proxy.enabled=true \
--set proxy.type=LoadBalancer \
--set enterprise.enabled=true \
--set enterprise.license_secret=kong-enterprise-license \
--set enterprise.portal.enabled=false \
--set enterprise.rbac.enabled=false \
--set enterprise.smtp.enabled=false \
--set manager.enabled=false \
--set portal.enabled=false \
--set portalapi.enabled=false \
--set env.status_listen=0.0.0.0:8100 \
--set secretVolumes[0]=kong-cluster-cert
```

**Note we're using the Control Plane's Kubernetes FQDN to get the Data Plane connected to it.**

#### Checking the Installation

```
kubectl get all -n kong-dp
```

**Sample Output**

```bash
kubectl get all -n kong-dp
NAME                               READY   STATUS    RESTARTS   AGE
pod/kong-dp-kong-d5bcf9c85-7f84r   1/1     Running   0          49s

NAME                         TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)                      AGE
service/kong-dp-kong-proxy   LoadBalancer   10.100.244.151   ace37937bca64475abb5252fcea93c1e-1822551085.us-east-1.elb.amazonaws.com   80:30191/TCP,443:30660/TCP   49s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/kong-dp-kong   1/1     1            1           49s

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/kong-dp-kong-d5bcf9c85   1         1         1       49s
```


#### Checking the Data Plane from the Control Plane

```bash
curl $CONTROL_PLANE_LB:8001/clustering/status
```

**Expected Output**

```bash
HTTP/1.1 200 OK
Access-Control-Allow-Origin: *
Connection: keep-alive
Content-Length: 179
Content-Type: application/json; charset=utf-8
Date: Thu, 08 Jul 2021 15:45:38 GMT
Deprecation: true
Server: kong/2.4.1.1-enterprise-edition
X-Kong-Admin-Latency: 3
X-Kong-Admin-Request-ID: rfGHCRf37yxTWX1c4J45IDLSrryfjNHb
vary: Origin

{
    "d1cd7bc3-f6da-4d06-aeea-884894ff4bc7": {
        "config_hash": "66f9770e92cc8e860fd7835e5d4c0adf",
        "hostname": "kong-dp-kong-75478bfcff-sq8f6",
        "ip": "192.168.16.247",
        "last_seen": 1625759130
    }
}
```



#### Checking the Data Plane Proxy

Use the Load Balancer created during the deployment

```bash
echo "export DATA_PLANE_LB=$(kubectl get svc -n kong-dp kong-dp-kong-proxy --output=jsonpath='{.status.loadBalancer.ingress[0].hostname}')" >> ~/.bashrc
bash
```

```
echo $DATA_PLANE_LB
```

```
curl $DATA_PLANE_LB
```
**NOTE** This step could take 2-3 minutes to show correctly as Kong Data plane try to connect with Kong Control Plane. You may receive `curl: (6) Could not resolve host:`. If you receive such message in output, wait for 2-3 minutes and retry.

**Expected Output**

```
HTTP/1.1 404 Not Found
Connection: keep-alive
Content-Length: 48
Content-Type: application/json; charset=utf-8
Date: Thu, 08 Jul 2021 15:47:34 GMT
Server: kong/2.4.1.1-enterprise-edition
X-Kong-Response-Latency: 0

{
    "message": "no Route matched with those values"
}
```

