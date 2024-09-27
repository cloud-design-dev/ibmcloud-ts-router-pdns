# Expose IBM Cloud Private DNS zones to Tailscale connected devices

## Overview

Use the Tailscale [Subnet Router](https://tailscale.com/kb/1019/subnets) feature along with IBM Cloud Custom Resolver to expose IBM Cloud Private DNS zones to Tailscale connected devices.

## Diagram

Here is a hgh level overview of the solution:

![Diagram of Tailscale deployment](./images/tailscale-pdns-vpc-overview.png)

Here is a closer look at the docker host that will run our sample services and expose them via Traefik:

![Diagram of Tailscale deployment](./images/tailscale-pdns-vpc-docker-host.png)

## Pre-reqs

- [ ] IBM Cloud [API Key](https://cloud.ibm.com/docs/account?topic=account-userapikey&interface=ui#create_user_key)
- [ ] Tailscale [API Key](https://login.tailscale.com/admin/settings/keys)
- [ ] Tailscale [Organization](https://login.tailscale.com/admin/settings/general). This is the name of your Tailnet Organization **not** your Tailnet DNS name.
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

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ssh_ip"></a> [allowed\_ssh\_ip](#input\_allowed\_ssh\_ip) | The IP address or CIDR block to allow SSH access from in to our Tailscale router instance. | `string` | `"0.0.0.0/0"` | no |
| <a name="input_existing_resource_group"></a> [existing\_resource\_group](#input\_existing\_resource\_group) | The IBM Cloud resource group to assign to the provisioned resources. | `string` | n/a | yes |
| <a name="input_existing_ssh_key"></a> [existing\_ssh\_key](#input\_existing\_ssh\_key) | The name of an existing SSH key to use for provisioning resources. If one is not provided, a new key will be generated. | `string` | `""` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud API key to use for provisioning resources | `string` | n/a | yes |
| <a name="input_ibmcloud_region"></a> [ibmcloud\_region](#input\_ibmcloud\_region) | The IBM Cloud region to use for provisioning VPCs and other resources. | `string` | n/a | yes |
| <a name="input_private_dns_zone"></a> [private\_dns\_zone](#input\_private\_dns\_zone) | Name of the private DNS zone to create for the VPCs | `string` | `"internal.lab"` | no |
| <a name="input_project_prefix"></a> [project\_prefix](#input\_project\_prefix) | The prefix to use for naming resources. If none is provided, a random string will be generated. | `string` | `""` | no |
| <a name="input_tailscale_api_key"></a> [tailscale\_api\_key](#input\_tailscale\_api\_key) | The Tailscale API key | `string` | n/a | yes |
| <a name="input_tailscale_organization"></a> [tailscale\_organization](#input\_tailscale\_organization) | The Tailscale Organization name for your Tailnet | `string` | n/a | yes |

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

When the provosion is complete, you should see the output of the plan, including the private IP addresses of the compute hosts, the advertised subnets, and our custom resolvers.

```shell
Apply complete! Resources: 38 added, 0 changed, 0 destroyed.

Outputs:

custom_resolver_ips = tolist([
  "10.250.0.5",
  "10.250.64.4",
])
lab_fqdns = [
  "whoami.ythd-internal.lab",
  "tools.ythd-internal.lab",
  "requests.ythd-internal.lab",
  "dashboard.ythd-internal.lab",
]
ts_router_subnet_cidr = "10.250.0.64/27"
workload_instance_ip = "10.250.0.4"
zone1_subnet_cidr = "10.250.0.0/26"
zone2_subnet_cidr = "10.250.64.0/26"

```

### Approve the advertised subnets in the Tailscale admin console

By default the subnet router will not advertise any of the subnets until they are approved in the Tailscale admin console. From the admin console, navigate to the Machines tab and click the subnet router instance name. On the machine details page you should see the subnets that are available to be advertised.

![Subnets awaiting advertisement approval](./images/awaiting-subnets.png)

Under **Approved** click `Edit` and select the subnets you want to advertise and click `Save`.

![Approving the subnets](./images/awaiting-subnets.png)

### Connect to Tailscale and check connectivity

Once the subnets are approved, you can start the Tailscale app on your local machine and set the local DNS resolvers to the custom resolvers that were created in the VPC. You can find the IP addresses of the custom resolvers in the terraform output. If you happen to be using a Mac, you can set the custom resolvers in the Network settings or via the command line with the `networksetup` command:

```shell
networksetup -setdnsservers Ethernet 10.250.0.5 10.250.64.4
```

With the resolvers set, we can now start testing connectivity to our deployed services. Take one of the FQDNs from the terraform output and try to connect to it.

```shell
curl "http://$(terraform output --json | jq -r '.lab_fqdns.value[0]')"
Hostname: 307a35892c5c
IP: 127.0.0.1
IP: ::1
IP: 172.18.0.5
RemoteAddr: 172.18.0.2:49386
GET / HTTP/1.1
Host: whoami.ygdg-internal.lab
User-Agent: curl/8.7.1
Accept: */*
Accept-Encoding: gzip
X-Forwarded-For: 10.250.0.4
X-Forwarded-Host: whoami.ygdg-internal.lab
X-Forwarded-Port: 80
X-Forwarded-Proto: http
X-Forwarded-Server: 71cfe6245938
X-Real-Ip: 10.250.0.4
```

![Browser test](https://images.gh40-dev.systems/Shared-Image-2024-09-13-11-32-46.png)

### Clean up

To remove the resources created by the terraform configuration, you can run the `destroy` command.

```shell
terraform destroy
```

## Conclusion

In this example we have deployed a Tailscale subnet router in an IBM Cloud VPC to expose private DNS services to our Tailscale network. We also created custom resolvers in the private DNS zone that allow us to connect to our private services using the FQDNs we have defined in the private DNS zone from our local machine.
