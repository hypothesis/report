## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.35 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2"></a> [ec2](#module\_ec2) | ./ec2 | n/a |
| <a name="module_rds"></a> [rds](#module\_rds) | ./rds | n/a |
| <a name="module_security"></a> [security](#module\_security) | ./security | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ./vpc | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_network_map"></a> [network\_map](#input\_network\_map) | A map containing network details | `map(any)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to all resources provisioned | `map(any)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ec2_map"></a> [ec2\_map](#output\_ec2\_map) | n/a |
| <a name="output_rds_address"></a> [rds\_address](#output\_rds\_address) | n/a |
| <a name="output_subnet_map"></a> [subnet\_map](#output\_subnet\_map) | n/a |
