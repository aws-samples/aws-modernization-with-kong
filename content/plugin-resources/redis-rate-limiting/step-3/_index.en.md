+++
title = "Scale Kong for Kubernetes to multiple pods"
weight = 13
+++


Lets first ensure HPA is turned off

```bash
kubectl delete hpa kong-dp-kong -n kong-dp
```

Now, let's scale up the Kong Ingress controller deployment to 3 pods, for scale ability and redundancy:

```bash
kubectl scale deployment/kong-dp-kong -n kong-dp --replicas=3
```


**Response**

```
deployment.extensions/ingress-kong scaled
```

#### Wait for replicas to deploy
It will take a couple minutes for the new pods to start up. Run the following command to show that the replicas are ready.

```bash
kubectl get pods -n kong-dp
```

```
NAME                              READY   STATUS    RESTARTS   AGE    IP               NODE                             NOMINATED NODE   READINESS GATES
kong-dp-kong-6649b7fccc-bxrqd     1/1     Running   0          118s   192.168.7.94     ip-192-168-12-141.ec2.internal   <none>           <none>
kong-dp-kong-6649b7fccc-v7fss     1/1     Running   0          118s   192.168.50.97    ip-192-168-47-143.ec2.internal   <none>           <none>
kong-dp-kong-6649b7fccc-xx22r     1/1     Running   0          137m   192.168.20.105   ip-192-168-12-141.ec2.internal   <none>           <none>
```

#### Verify traffic control
Test the rate-limiting policy by executing the following command and observing the rate-limit headers.

```bash
curl -I $DATA_PLANE_LB/foo-redis/headers
```

**Response**

```bash
HTTP/1.1 200 OK
Content-Type: text/plain; charset=UTF-8
Connection: keep-alive
Server: echoserver
X-RateLimit-Limit-minute: 5
X-RateLimit-Remaining-minute: 4
demo:  injected-by-kong
X-Kong-Upstream-Latency: 1
X-Kong-Proxy-Latency: 2
Via: kong/2.x
```

#### Results
You will observe that the rate-limit is not consistent anymore and you can make more than 5 requests in a minute.

To understand this behavior, we need to understand how we have configured Kong. In the current policy, each Kong node is tracking a rate-limit in-memory and it will allow 5 requests to go through for a client. There is no synchronization of the rate-limit information across Kong nodes. In use-cases where rate-limiting is used as a protection mechanism and to avoid over-loading your services, each Kong node tracking it's own counter for requests is good enough as a malicious user will hit rate-limits on all nodes eventually. Or if the load-balance in-front of Kong is performing some sort of deterministic hashing of requests such that the same Kong node always
receives the requests from a client, then we won't have this problem at all.

#### Whats Next ?
In some cases, a synchronization of information that each Kong node maintains in-memory is needed. For that purpose, Redis can be used. Let's go ahead and set this up next.