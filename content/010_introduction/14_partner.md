---
title: "What is Armory Enterprise?"
chapter: true
weight: 14
---

# Enter Armory 
## Enabling Secure, Reliable, and Safe Deployments at Scale

Out of the box, Armory provides automation for deploying your software at scale. In addition, Armory integrates with the most common DevOps tools and provides you with the tools you need to manage:

- Production Permissions and Entitlements
- Policy Enforcement
- Production Architectural Best Practice Enforcement
- Blue/Green Deployments
- Canary Deployments
- Native Kubernetes Deployments

Armory has open source Spinnaker at its core and provides value to multiple personas within your org:  

- For platform/ops: consistent & compliant deployments that support multi-target & multi-cloud
- For developers: platform to rapidly and confidently ship features to target infrastructure using industry best practices
- For all: a centralized view into deployments at scale, with consistent guardrails, deployment best practices, and policies to secure trust and confidence.
- Open APIs support integrating to your existing CI process


Some highlights of Armory Enterprise:

- [Armory Operator](https://docs.armory.io/docs/installation/armory-operator/) is a Kubernetes Operator that helps you configure, deploy, and update Armory Enterprise on Kubernetes clusters.
- [Armory Agent for Kubernetes](https://docs.armory.io/docs/armory-agent/) is a lightweight, scalable service that monitors your Kubernetes infrastructure and streams changes back to Armory’s Clouddriver service.
- [Pipelines as Code (Dinghy)](https://docs.armory.io/docs/spinnaker-user-guides/using-dinghy/) allows you to store Armory pipelines in Github and manage them like you would manage code, including version control, templatization, and modularization. Armory pipelines are flexible and customizable series of deployment stages. Combine all these to rapidly and repeatably scale pipelines in your Armory deployment.
- [Policy Engine](https://docs.armory.io/docs/armory-admin/policy-engine-enable/) helps you meet compliance requirements based on custom policies you set. You can configure the Policy Engine to verify that your pipelines meet certain requirements at save time or at runtime.
- [Terraform integration](https://docs.armory.io/docs/spinnaker-user-guides/terraform-use-integration/) allows you to use your existing Terraform scripts to plan and create infrastructure as part a Armory pipeline. You can deploy your application and infrastructure all in a single pipeline.


Why would you want to travel any other way?

![Smooth sailing with Armory Enterprise](/images/Armory-highway.jpeg)

