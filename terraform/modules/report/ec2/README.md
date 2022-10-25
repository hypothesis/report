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
| [aws_instance.linux](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_network_map"></a> [network\_map](#input\_network\_map) | n/a | `map(any)` | n/a | yes |
| <a name="input_security_map"></a> [security\_map](#input\_security\_map) | n/a | `map(any)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ec2_ip_info"></a> [ec2\_ip\_info](#output\_ec2\_ip\_info) | n/a |
| <a name="output_ec2_map"></a> [ec2\_map](#output\_ec2\_map) | n/a |
