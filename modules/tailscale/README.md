# Tailscale aws deployment

## prequisites 
- Create a tailscale account
- Get an api key - https://login.tailscale.com/admin/settings/keys
- Manually add api key to AWS SSM with the following name scheme `[env]-[project]-tailscale-api-key`
    - `env` and `project` should be set passed into the terrafrom vars
- Get your tailnet name - https://tailscale.com/kb/1136/tailnet/ 

## module variables
| name | purpose |
| `env` | the environment in which the device will deployed in and used as a name prefix |
| `region` | the aws region for the deployment |
| `project` | an overall namespace the tailnet device is a part of |
| `tailnet` | the tailscale's tailnet name |
| `vpc_id` | the aws vpc id |
| `relayed_subnet_id` | the aws vpc subnet id the device will live in |
| `subnets_to_advertise` | a list of private subnet cidrs the device will make reachable |

## tailscale-relay-init.sh 
This script is only run at the time ec2 instance is created through as aws user data. Rebooting the instance will not re-run the script.

This script does the following on instance creation.
- Enables ip forwarding - required for subnet routing 
- Enables tailscale daemon to start on boot - required to enable connection on reboots
- Removes devices from the tailnet with same name - combat dynamic ip creating multiple devices on the tailnet 
- Gets a tailnet auth token from tailscale using an api token - security 
- Connects to the tailnet and exposed private subnets- main motivation 
- Disable the auth token expiry date - quality of life decision
- Removes api token from logs and files where displayed in plain text - security

Since the tailscale daemon starts on boot, the ec2 instance will reconnect to the tailnet on boot as well. There's is no need to get the auth token from tailscale.

Note: The name of the `tailnet_device_name` is treated as a unique identifier, it will remove any existing device from the tailnet with this name.
Note: tailscale api token generate a single auth token. The retreived auth token is configured for only device to connect to tailnet at a time with it.:w

## cautions
If dns config needs to change, be sure when connecting to tailnet that user devices connectivity to the broader internet are not disturbed. 
If latency becomes an issue, look into the benefits of exposing port udp 41641 on the device.

## resources
- Tailnet and AWS: https://tailscale.com/kb/1021/install-aws/
- Connecting to RDS: https://tailscale.com/kb/1141/aws-rds/
- Tailnet API: https://github.com/tailscale/tailscale/blob/main/api.md
- AWS user data: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html
- AWS VPC DNS: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-dns.html
