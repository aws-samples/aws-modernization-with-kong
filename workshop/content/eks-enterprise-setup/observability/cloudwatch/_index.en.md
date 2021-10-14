+++
title = "AWS CloudWatch"
weight = 12
+++

In this module, we will learn

1. Configuring CloudWatch Agent to Collect Cluster Metrics and FluentBit for logs.
2. Configuring Kong Enterprise to output metrics and logs to AWS CloudWatch. 
3. Query Logs in AWS Cloudwatch insights

#### Install CloudWatch Metrics and FluentD Daemonsets

Attach role to EKS dataplane nodes

```bash
aws iam attach-role-policy \
  --role-name $ROLE_NAME \
  --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy
```


The command below will:

* Create the `Namespace` amazon-cloudwatch.
* Create all the necessary security objects for both DaemonSet:
  * `SecurityAccount`.
  * `ClusterRole`.
  * `ClusterRoleBinding`.
* Deploy Cloudwatch-Agent (responsible for sending the **metrics** to CloudWatch) as a `DaemonSet`.
* Deploy fluentd (responsible for sending the **logs** to Cloudwatch) as a `DaemonSet`.
* Deploy `ConfigMap` configurations for both DaemonSets.


```bash
curl -s https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluentd-quickstart.yaml | sed "s/{{cluster_name}}/${EKS_CLUSTERNAME}/;s/{{region_name}}/${AWS_REGION}/" | kubectl apply -f -
```

{{% notice note %}}
You can find the full information and manual install steps [here](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-EKS-quickstart.html).
{{% /notice %}}


You can verify all the `DaemonSets` have been deployed by running the following command.

```bash
kubectl -n amazon-cloudwatch get daemonsets
```

Output

```
NAME                 DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
cloudwatch-agent     3         3         3       3            3           <none>          2m43s
fluentd-cloudwatch   3         3         3       3            3           <none>          2m43s
```


#### Configuring Kong Enterprise to output metrics and logs to AWS CloudWatch. 

We will use File Log plugin to source Kong's request and response data in JSON format to `/dev/stdout` , which then will be picked up by the FluentD daemonsets and sent to CloudWatch Logs.

```bash
echo '
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: global-file-log
config: 
  path: /dev/stdout
  reopen: false
plugin: file-log
' | kubectl apply -f -
```
