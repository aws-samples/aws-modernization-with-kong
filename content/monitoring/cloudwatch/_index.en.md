+++
title = "AWS CloudWatch"
weight = 11
+++

#### Querying CloudWatch Logs

```bash
filter kubernetes.namespace_name='kong-dp'
| parse log '"upstream_uri":"*"' as upstream_uri
| parse log '"request":{"uri":"*","url":"*","querystring":*,"headers":{"accept-encoding":"*","connection":"*","user-agent":"*","accept":"*","host":"*"},"size":*,"method":"*"}' as request_uri, request_uri, request_url, request_querystring, request_encoding, request_connection, request_user_agent, request_accept, request_host, request_host, request_size, request_method
| parse log '"workspace":"*"' as workspace
| filter ispresent(request_uri)
```