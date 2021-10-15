+++
title = "Authentication-OpenID Connect"
weight = 17
+++

OpenID Connect (1.0) plugin allows the integration with a 3rd party identity provider (IdP) in a standardized way. This plugin can be used to implement Kong as a (proxying) [OAuth 2.0](https://tools.ietf.org/html/rfc6749) resource server (RS) and/or as an OpenID Connect relying party (RP) between the client, and the upstream service.

The plugin supports several types of credentials and grants:

Signed JWT access tokens (JWS)
Opaque access tokens
Refresh tokens
Authorization code
Username and password
Client credentials
Session cookies

In this workshop, we will configure this plugin to use [Amazon Cognito](https://aws.amazon.com/cognito/) . A detailed integration guide is available [here](https://docs.konghq.com/enterprise/2.6.x/plugins/oidc-cognito/) for future reading.

#### Creating AWS Cognito

First of all, let's create a Cognito instance using the AWS Console

* Navigate to AWS Console by clicking [this deep link](https://us-east-2.console.aws.amazon.com/cognito/home?region=us-east-2#) and click on **Managed User Pools** and on **Create a user pool**.
* Name your pool as **kongpool** and click on **Step through settings**.
* Select **Email address or phone number** and, under that, select **Allow email addresses**.
* Select the following standard attributes as required
  * email
  * family name
  * given name

![cognito1](/images/cognito1.png)


* Click on **Next step**.
* For the next pages, **Policies**, **MFA and verifications**, **Message customizations** and **Tags**, click on **Next step**.
* In the page **Devices**, select **No** for **Do you want to remember your user’s devices** and click on **Next step**.
* In the pages **App clients** and **Triggers** click on **Next step**.
* In the page **Review** click on **Create pool**. Take note of the **Pool Id**.

![cognito2](/images/cognito2.png)




#### Application Definition
* Click on **App clients** left menu option.

* Click on **Add an app client** and enter with the following data:
  * App client name: kong-api
  * Refresh token expiration (days): 30
  * Generate client secret: on
  * Enable lambda trigger based custom authentication (ALLOW_CUSTOM_AUTH): off
  * Enable username password based authentication (ALLOW_USER_PASSWORD_AUTH): on
  * Enable SRP (secure remote password) protocol based authentication (ALLOW_USER_SRP_AUTH): off

* Click on **Set attribute read and write permissions**<p>
Uncheck everything except the **email**, **family name** and **given name** fields.

![cognito3](/images/cognito3.png)

* Click on **Create app client** and on **Show details**

* Take note of the **App client id**.

* Click on **Details** and take note of the **App client secret**. 

![cognito4](/images/cognito4.png)






#### Register the Ingress endpoint in Cognito
Return to your Cognito User Pool to register the Ingress.

* Click on **App integration** -> **App client settings**.
* Click the **Cognito User Pool**

In the **Callback URL(s)** field type insert your URLs like this. Note that AWS Cognito doesn’t support HTTP callback URLs. This field should include the Ingresses that you want to secure using AWS Cognito. For this workshop, get the output from `echo $DATA_PLANE_LB/bar` and mention in this field.

* Click **Authorization code grant**.
* Click **email**, **openid**, **aws.cognito.signin.user.admin** and **profile**.

![cognito5](/images/cognito5.png)


* Click on **Save changes**.
* Click on **Choose domain name**.

In the **Domain prefix** field type **kongidp** and click on **Check availability** to make sure it's available.

![cognito6](/images/cognito6.png)


* Click on **Save changes**.




#### Test the Ingress

```bash
curl -i $DATA_PLANE_LB/bar 
```

**Exected Output**

```bash
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 45
Content-Type: text/html; charset=utf-8
Date: Fri, 08 Oct 2021 12:40:56 GMT
Server: Werkzeug/1.0.1 Python/3.7.4
Via: kong/2.5.1.0-enterprise-edition
X-Kong-Proxy-Latency: 1
X-Kong-Upstream-Latency: 1
```