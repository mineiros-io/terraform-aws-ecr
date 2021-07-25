[<img src="https://raw.githubusercontent.com/mineiros-io/brand/3bffd30e8bdbbde32c143e2650b2faa55f1df3ea/mineiros-primary-logo.svg" width="400"/>][homepage]

[![license][badge-license]][apache20]
[![Terraform Version][badge-terraform]][releases-terraform]
[![Join Slack][badge-slack]][slack]

# What this example shows

This example creates an ECR repository and attach a lifecycle policy.

## Basic usage

The code in [main.tf] defines the following module

```hcl
module "repository" {
  source  = "mineiros-io/ecr/aws"
  version = "~> 0.4.0"

  name = "example"

  immutable = true

  push_identities = []
  pull_identities = []

  lifecycle_policy_rules = [
    {
      rulePriority : 1,
      description : "Expire untagged images older than 90 days",
      selection : {
        tagStatus : "untagged",
        countType : "sinceImagePushed",
        countUnit : "days",
        countNumber : 90
      },
      action : {
        type : "expire"
      }
    },
    {
      rulePriority : 2,
      description : "Only keep the most recent 20 images",
      selection : {
        tagStatus : "any",
        countType : "imageCountMoreThan",
        countNumber : 20
      },
      action : {
        type : "expire"
      }
    }
  ]
}
```

## Running the example

### Cloning the repository

```bash
git clone https://github.com/mineiros-io/terraform-aws-ecr.git
cd terraform-aws-ecr/examples/ecr
```

### Initializing Terraform

Run `terraform init` to initialize the example and download providers and the module.

### Planning the example

Run `terraform plan` to see a plan of the changes.

### Applying the example

Run `terraform apply` to create the resources.
You will see a plan of the changes and Terraform will prompt you for approval to actually apply the changes.

### Destroying the example

Run `terraform destroy` to destroy all resources again.

<!-- References -->

[main.tf]: https://github.com/mineiros-io/terraform-aws-ecr/blob/master/examples/ecr/main.tf

[homepage]: https://mineiros.io/?ref=terraform-aws-ecr

[badge-license]: https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg
[badge-terraform]: https://img.shields.io/badge/terraform-1.x%20|%200.15%20|%200.14%20|%200.13%20|%200.12.20+-623CE4.svg?logo=terraform
[badge-slack]: https://img.shields.io/badge/slack-@mineiros--community-f32752.svg?logo=slack

[releases-terraform]: https://github.com/hashicorp/terraform/releases
[apache20]: https://opensource.org/licenses/Apache-2.0
[slack]: https://join.slack.com/t/mineiros-community/shared_invite/zt-ehidestg-aLGoIENLVs6tvwJ11w9WGg
