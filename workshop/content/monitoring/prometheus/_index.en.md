+++
title = "Metrics"
weight = 11
+++

#### Generate Load

Use Fortio to start injecting some request to the Data Plane

```bash
fortio load -c 120 -qps 2000 -t 0 http://$DATA_PLANE_LB/sampleroute/hello
```

#### Check Grafana

Direct your browser to Grafana again. You can get the Grafana URL by running `echo $GRAFANA_LB` if required. Click on **Dashboards** and **Manage**. Choose the **Kubernetes/Computer Resources/Namespaces (Pods)** dashboard. Choose the **kong-dp** namespace.

![grafana_pods1](/images/grafana_pods1.png)


#### Check HPA

Since we're using HPA, the number of Pods should increase to satify our settings.

![grafana_pods2](/images/grafana_pods2.png)

In fact, we can see the new current HPA status with:

```bash
kubectl get hpa -n kong-dp
```

**Expected Output**

```bash
NAME           REFERENCE                 TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
kong-dp-kong   Deployment/kong-dp-kong   15%/75%   1         20        3          15h
```

#### Consume the new Prometheus Service

Copy the output from the following command and open in your browser

```bash
echo $PROM_OPERATED_LB:9090
```

Access the metrics by entering `kong_http_status` as example 

![service_monitor2](/images/service_monitor2.png)


#### Accessing Grafana

You should be able to see Kong Data Plane metrics now in Kong's dashboard.
You can open Grafana by coping the output from `echo $GRAFANA_LB` and pasting in browser.

![grafana_dashboard1](/images/grafana_dashboard1.png)

