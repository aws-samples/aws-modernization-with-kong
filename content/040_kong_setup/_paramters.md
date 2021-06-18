---
title: "Run Armory Quickstart"
chapter: true
draft: false
weight: 1
---

## Parameters

The CloudFormation template provides an opportunity to provide values that will be used to customize the resources required for Armory Enterprise. The important values to enter:

- Availability Zones - for the workshop purposes one availability zone is enough
- SSH key name - choose SSH Key pair created in the prerequisites or any other you usually use in this region
- Allowed external access CIDR - for the workshop purpose you can use 0.0.0.0/0 to allow all IPv4 addresses to access Bastion host
- Number of Availability zones - needs to match the number of zones listed above
- EKS Public Access Point - set it to "Enabled"
- Instance type - should be a t3.xlarge or greater

After entering the desired values, press "Next"

![stack-details](/images/stack-details.png)

## Stack Options

For this workshop, accept the default values and press "Next"

## Review

- Review the values you entered.
- Accept the acknowledgments at the bottom of the page.
- Press "Create Stack".

Note: It will take about 50 minutes to create all the stacks.

Once completed you can navigate to the main stack "Armory-Spinnaker-on-EKS-New-VPC", got to "Outputs" and find "SpinnakerUI" (to be validated)
