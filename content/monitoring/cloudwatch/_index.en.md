+++
title = "AWS CloudWatch"
weight = 11
+++

#### Viewing CloudWatch Logs

Observe the log groups at [in the console](https://us-east-2.console.aws.amazon.com/cloudwatch/home?region=us-east-2#logsV2:log-groups). You will notice the following log groups per cluster

* /aws/containerinsights/{ClusterName}}/application
* /aws/containerinsights/{ClusterName}}/host
* /aws/containerinsights/{ClusterName}}/dataplane
* /aws/containerinsights/{ClusterName}}/performance 
#### Querying CloudWatch Logs using logs insights

Click on `/aws/containerinsights/{ClusterName}}/application` and **View in Logs Insights**. Run the following query, which details the entire request and response logged using Kong Plugin

```bash
filter kubernetes.namespace_name='kong-dp'
| parse log '"upstream_uri":"*"' as upstream_uri
| parse log '"request":{"uri":"*","url":"*","querystring":*,"headers":{"accept-encoding":"*","connection":"*","user-agent":"*","accept":"*","host":"*"},"size":*,"method":"*"}' as request_uri, request_uri, request_url, request_querystring, request_encoding, request_connection, request_user_agent, request_accept, request_host, request_host, request_size, request_method
| parse log '"workspace":"*"' as workspace
| filter ispresent(request_uri)
```