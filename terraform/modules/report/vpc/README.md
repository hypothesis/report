## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eip.eips](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.nat_gateways](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.default_private_routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.default_public_routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.route_tables](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.route_table_associations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_peering_connection.peers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env_map"></a> [env\_map](#input\_env\_map) | n/a | `map(any)` | <pre>{<br>  "cidr": "10.10.0.0/16",<br>  "linux_ami": "ami-095509bf36d02a8e0",<br>  "name": "report",<br>  "region": "ca-central-1"<br>}</pre> | no |
| <a name="input_network_map"></a> [network\_map](#input\_network\_map) | n/a | `map(any)` | <pre>{<br>  "subnet_four": {<br>    "az": "cac1-az2",<br>    "cidr": "10.10.4.0/24",<br>    "nat": "subnet_two",<br>    "public": false,<br>    "suffix": "sn4"<br>  },<br>  "subnet_one": {<br>    "az": "cac1-az1",<br>    "cidr": "10.10.1.0/24",<br>    "public": true,<br>    "suffix": "sn1"<br>  },<br>  "subnet_three": {<br>    "az": "cac1-az1",<br>    "cidr": "10.10.3.0/24",<br>    "nat": "subnet_one",<br>    "public": false,<br>    "suffix": "sn3"<br>  },<br>  "subnet_two": {<br>    "az": "cac1-az2",<br>    "cidr": "10.10.2.0/24",<br>    "public": true,<br>    "suffix": "sn2"<br>  }<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID VPC. |
| <a name="output_vpc_map"></a> [vpc\_map](#output\_vpc\_map) | A collection of useful VPC information. |
