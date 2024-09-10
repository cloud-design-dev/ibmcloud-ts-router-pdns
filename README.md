# Expose IBM Cloud Private DNS zones to Tailscale connected devices

## Overview

Use the Tailscale [Subnet Router](https://tailscale.com/kb/1019/subnets) feature along with IBM Cloud Custom Resolver to expose IBM Cloud Private DNS zones to Tailscale connected devices.

## Diagram

![Diagram of Tailscale deployment](./images/tailscale-pdns-vpc.png)

## Pre-reqs

- [ ] IBM Cloud [API Key](https://cloud.ibm.com/docs/account?topic=account-userapikey&interface=ui#create_user_key)
- [ ] Tailscale [API Key](https://login.tailscale.com/admin/settings/keys)
- [ ] Terraform [installed](https://developer.hashicorp.com/terraform/install) locally

## Getting started

### Clone repository and configure terraform variables

The first step is to clone the repository and configure the terraform variables.

```shell
git clone https://github.com/cloud-design-dev/ibmcloud-ts-router-pdns.git
cd ibmcloud-vpc-ts-router
```

Copy the example terraform variables file and update the values with your own.

```shell
cp tfvars-template terraform.tfvars
```

#### Variables 

 - [ ] todo: use terraform-docs utility to generate documentation for the variables and add in table 

### Initialize, Plan and Apply the Terraform configuration

Once you have the required variables set, you can initialize the terraform configuration and create a plan for the deployment.

```shell
terraform init
terraform plan -out=plan.out
```

If no errors are returned, you can apply the plan to create the VPCs, subnets, and compute instances.

```shell
terraform apply plan.out
```

When the provosion is complete, you should see the output of the plan, including the private IP addresses of the compute hosts.

```shell
Apply complete! Resources: 41 added, 0 changed, 0 destroyed.

Outputs:

dev_node_ip = "172.16.64.4"
dev_vpc_subnet = "172.16.64.0/26"
hub_vpc_subnet = "192.168.0.0/26"
prod_node_ip = "172.16.0.4"
prod_vpc_subnet = "172.16.0.0/26"
ts_router_ip = "192.168.0.4"
```

### Approve the advertised subnets in the Tailscale admin console

By default the subnet router will not advertise any of the subnets until they are approved in the Tailscale admin console. From the admin console, navigate to the Machines tab and click the subnet router instance name. On the machine details page you should see the subnets that are available to be advertised.

![Subnets awaiting advertisement approval](./images/awaiting-approval-subnets.png)

Under **Approved** click `Edit` and select the subnets you want to advertise and click `Save`.

![Approving the subnets](./images/subnet-approve.png)

### Connect to Tailscale and check connectivity

Once the subnets are approved, you can start the Tailscale app on your local machine and start testing connectivity to the private IP addresses of our VPC compute instances.

```shell
curl http://$(terraform output whoami_fqdn)

# or

ssh root@<prod_node_ip>
```

### Clean up

To remove the resources created by the terraform configuration, you can run the `destroy` command.

```shell
terraform destroy
```

## Conclusion

In this example we have deployed a Tailscale subnet router in a hub IBM Cloud VPC and connected it to two spoke VPCs in the same region using a Transit Gateway. This allows us to connect in to our compute in these VPCs without the need for each device to be running the Tailscale agent.
