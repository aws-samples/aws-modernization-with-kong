+++
title = "Data Plane Metrics to Prometheus"
weight = 11
+++

In order to monitor the Kong Data Planes replicas we're going to configure a Service Monitor based on a Kubernetes Service created for the Data Planes. 


#### Create a Global Prometheus plugin

First of all we have to configure the specific Prometheus plugin provided by Kong. After submitting the following declaration, all Ingresses defined will have the plugin enabled and, therefore, include their metrics on the Prometheus endpoint exposed by the Kong Data Plane.

Execute the following command

```bash
cat <<EOF | kubectl apply -f -
apiVersion: configuration.konghq.com/v1
kind: KongClusterPlugin
metadata:
  name: prometheus
  annotations:
    kubernetes.io/ingress.class: kong
  labels:
    global: "true"
plugin: prometheus
EOF
```

#### Expose the Data Plane metrics endpoint with a Kubernetes Service

The next thing to do is to expose the Data Plane metrics port as a new Kubernetes Service. The new Kubernetes Service will be consumed by the Prometheus Service Monitor we're going to configure later.

The new Kubernetes Service will be based on the metrics port 8100 provided by the Data Plane. We set the port during the Data Plane installation using the parameter <b>\-\-set env.status_listen=0.0.0.0:8100</b>. You can check the port running:

```bash
kubectl describe pod kong-dp-kong -n kong-dp | grep Ports
```

**Expected Output**

```bash
    Ports:          8000/TCP, 8443/TCP, 8100/TCP
    Host Ports:     0/TCP, 0/TCP, 0/TCP
```

To create a new Kubernetes Service to expose the Data Plane metrics, execute the following

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: kong-dp-monitoring
  namespace: kong-dp
  labels:
    app: kong-dp-monitoring
spec:
  selector:
    app.kubernetes.io/name: kong
  type: ClusterIP
  ports:
  - name: metrics
    protocol: TCP
    port: 8100
    targetPort: 8100
EOF
```

Note that the new Kubernetes Service is selecting the existing Data Plane Kubernetes Service using its specific label **app.kubernetes.io/name: kong**

Use can check the label running


```bash
kubectl get service -n kong-dp -o wide
```


**Expected Output**

```bash

NAME                 TYPE           CLUSTER-IP     EXTERNAL-IP                                                                  PORT(S)                      AGE
kong-dp-kong-proxy   LoadBalancer   10.100.12.30   a6bf3f71a14a64dba850480616af8fc9-1188819016.eu-central-1.elb.amazonaws.com   80:32336/TCP,443:31316/TCP   54m
kong-dp-monitoring   ClusterIP      10.100.91.54   <none>                                                                       8100/TCP                     66s
```

#### Test the service.

On one local terminal, expose the port 8100 using **port-forward**

```bash
kubectl port-forward service/kong-dp-monitoring -n kong-dp 8100
```

**Expected Output**

```bash
Forwarding from 127.0.0.1:8100 -> 8100
Forwarding from [::1]:8100 -> 8100
```

Now open another tab from your Cloud9 environment (go to **Actions** > **New Tab**)

```bash
curl localhost:8100/metrics
```

**Sample Output**

```bash
# HELP kong_datastore_reachable Datastore reachable from Kong, 0 is unreachable
# TYPE kong_datastore_reachable gauge
kong_datastore_reachable 1
# HELP kong_enterprise_license_errors Errors when collecting license info
# TYPE kong_enterprise_license_errors counter
kong_enterprise_license_errors 1
# HELP kong_memory_lua_shared_dict_bytes Allocated slabs in bytes in a shared_dict
# TYPE kong_memory_lua_shared_dict_bytes gauge
kong_memory_lua_shared_dict_bytes{shared_dict="kong"} 40960
………….
```

#### Create the Prometheus Service Monitor

Now, let's create the Prometheus Service Monitor collecting metrics from all Data Planes instances. The Service Monitor is based on the new **kong-dp-monitoring** Kubernetes Service we created before:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: kong-dp-service-monitor
  namespace: kong-dp
  labels:
    release: kong-dp
spec:
  namespaceSelector:
    any: true
  endpoints:
  - port: metrics       
  selector:
    matchLabels:
      app: kong-dp-monitoring
EOF
```

#### Starting a Prometheus instance for the Kong Data Plane
A specific Prometheus instance will be created to monitor the Kong Data Plane using a specific "kong-prometheus" account. Before doing it, we need to create the account and grant specific permissions.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kong-prometheus
  namespace: kong-dp
EOF
```

```bash
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: prometheus
rules:
- apiGroups: [""]
  resources:
  - nodes
  - nodes/metrics
  - services
  - endpoints
  - pods
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources:
  - configmaps
  verbs: ["get"]
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses
  verbs: ["get", "list", "watch"]
- nonResourceURLs: ["/metrics"]
  verbs: ["get"]
EOF
```

```bash
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: prometheus
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus
subjects:
- kind: ServiceAccount
  name: kong-prometheus
  namespace: kong-dp
EOF
```

Instantiate a Prometheus Service for the Kong Data Plane

```bash
cat <<EOF | kubectl apply -f -
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: kong-dp-prometheus
  namespace: kong-dp
spec:
  serviceAccountName: kong-prometheus
  serviceMonitorSelector:
    matchLabels:
      release: kong-dp
  resources:
    requests:
      memory: 400Mi
  enableAdminAPI: true
EOF
```
Expose the new Prometheus service

```bash
kubectl expose service prometheus-operated --name prometheus-operated-lb -n kong-dp
```

```bash
kubectl get service -n kong-dp
```

**Expected Output**

```bash
NAME                     TYPE           CLUSTER-IP      EXTERNAL-IP                                                               PORT(S)                      AGE
kong-dp-kong-proxy       LoadBalancer   10.100.11.50    a31effa06182047d7b6f24af2d938054-1892572230.us-east-2.elb.amazonaws.com   80:30251/TCP,443:32310/TCP   56m
kong-dp-monitoring       ClusterIP      10.100.22.163   <none>                                                                    8100/TCP                     5m36s
prometheus-operated      ClusterIP      None            <none>                                                                    9090/TCP                     4m1s
prometheus-operated-lb   ClusterIP      10.100.26.253   <none>                                                                    9090/TCP                     5s
```

#### Adding New Prometheus Service to Grafana

Create a new Grafana Data Source based on the Prometheus Service URL: **http://prometheus-operated.kong-dp.svc.cluster.local:9090**

To do so, copy the **output** from the following command and open in a browser.

```bash
echo $GRAFANA_LB/datasources/new
```

Select **Prometheus** , paste **http://prometheus-operated.kong-dp.svc.cluster.local:9090** in HTTP > URL section and hit **Save & Test**

![grafana_newdatasource](/images/grafana_newdatasource.png)

Now, based on this new Data Source, import the official Kong Grafana Dashboard with id **7424**

To do so, copy the **output** from the following command and open in a browser.

```bash
echo $GRAFANA_LB/dashboard/import
```
Enter **7424** under "Import via grafana.com" > **Load**

![grafana_newdashboard](/images/grafana_newdashboard.png)

You should be able to see Kong Data Plane metrics now:

![grafana_dashboard1](/images/grafana_dashboard1.png)

