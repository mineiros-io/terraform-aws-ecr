<img src="https://i.imgur.com/t8IkKoZl.png" width="200"/>

[![Maintained by Mineiros.io](https://img.shields.io/badge/maintained%20by-mineiros.io-00607c.svg)](https://www.mineiros.io/ref=terraform-aws-ecr)
[![Build Status](https://mineiros.semaphoreci.com/badges/terraform-aws-ecr/branches/master.svg?style=shields)](https://mineiros.semaphoreci.com/badges/terraform-aws-ecr/branches/master.svg?style=shields)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/mineiros-io/terraform-aws-ecr.svg?label=latest&sort=semver)](https://github.com/mineiros-io/terraform-aws-ecr/releases)
[![Terraform Version](https://img.shields.io/badge/terraform-~%3E%200.12.20-brightgreen.svg)](https://github.com/hashicorp/terraform/releases)
[![License](https://img.shields.io/badge/License-Apache%202.0-brightgreen.svg)](https://opensource.org/licenses/Apache-2.0)

# terraform-aws-ecr
A [Terraform](https://www.terraform.io) 0.12 base module for
[creating a service](https://aws.amazon.com/service/) on
[Amazon Web Services (AWS)](https://aws.amazon.com/).

- [Module Features](#module-features)
- [Getting Started](#getting-started)
- [Module Argument Reference](#module-argument-reference)
- [Module Attributes Reference](#module-attributes-reference)
- [Module Versioning](#module-versioning)
- [About Mineiros](#about-mineiros)
- [Reporting Issues](#reporting-issues)
- [Contributing](#contributing)
- [License](#license)

## Module Features
In contrast to the plain `aws_ecr_repository` resource this module enables you to easily
grant cross account pull or push access to the repository.

- **Default Security Settings**:
  Image Scanning is enabled by default and you need to opt-out to disable it by setting `scan_on_push = false`.
  Least needed privileges are applied for managed pull and push identities.

- **Standard Module Features**:
  Create an ECR repository

- **Extended Module Features**:
  Attach a repository policy,
  Attach a lifecycle policy

- **Additional Features**:
  Grant pull access to AWS identities (cross account),
  Grant pull&push access to AWS identities (crosss account)

- *Features not yet implemented*:
  Easy lifecycle rule setup

## Getting Started
Most basic usage creating an ECR repository.
To configure aws terraform provider credentials we recommend to set the environment variables
`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` and not configure them inside `.tf`-files
or using terraform variables (`.tfvars` files) as those values might end up in terraforms state file
or in github commits.

```hcl
provider "aws" {
  version = "~> 2.45"
  region  = "us-east-1"
}

module "resource" {
  source  = "mineiros-io/ecr/aws"
  version = "0.0.1"

  name = "example"
}
```

## Module Argument Reference
See
[variables.tf](https://github.com/mineiros-io/terraform-aws-ecr/blob/master/variables.tf)
and
[examples/](https://github.com/mineiros-io/terraform-aws-ecr/blob/master/examples)
for details and use-cases.

#### Top-level Arguments

##### Main Resource Configuration
- **`name`**: **(Required `string`, Forces new resource)**
The name of the repository.

- **`module_enabled`**: *(Optional `bool`)*
Specifies whether resources in this module should be created.
Default is `true`.

- **`immutable`**: *(Optional `string`)*
You can configure a repository to be immutable to prevent image tags from being overwritten.
Defaults to `false`.

- **`immutable`**: *(Optional `map(string)`)*
A mapping of tags to assign to the resource. Defaults to `{}`.

- **`scan_on_push`**: *(Optional `map(string)`)*
Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false).
Defaults to `false`.

##### Extended Resource configuration
- **[`repository_policy_statements`](#policy_statement-object-arguments)**: *(Optional `list(policy_statements)`)*
List of statements of the repository policy.
Default is `[]`.

- **[`repository_lifecycle_rules`](#lifecycle_rule-object-arguments)**: *(Optional `list(lifecycle_rules)`)*
List of lifecycle policy rules.
Default is `[]`.

##### Additional configuration
- **`pull_identities`**: *(Optional `list(string)`)*
List of AWS identity identifiers to grant cross account pull access to.
Default is `[]`.

- **`push_identities`**: *(Optional `list(string)`)*
List of AWS identity identifiers to grant cross account pull and push access to.
Default is `[]`.

#### [`policy_statements`](#main-resource-configuration) Object Arguments
- **`sid`**: *(Optional `string`)*
An ID for the policy statement.

- **`effect`**: *(Optional `string`)*
Either "Allow" or "Deny", to specify whether this statement allows or denies the given actions.
Default is "Allow".

- **`actions`**: *(Optional `list(string)`)*
A list of actions that this statement either allows or denies.

- **`not_actions`**: *(Optional `list(string)`)*
A list of actions that this statement does not apply to.
Used to apply a policy statement to all actions except those listed.

- **[`principals`](#principal-object-arguments)**: *(Optional `list(principal)`)*
A nested configuration block (described below) specifying a resource (or resource pattern) to which this statement applies.

- **[`not_principals`](#principal-object-arguments)**: *(Optional `list(principal)`)*
Like principals except gives resources that the statement does not apply to.

##### [`principal`](#policy_statement-object-arguments) Object Arguments
- **`type`**: *(Optional `string`)*
The type of principal. For AWS ARNs this is "AWS". For AWS services (e.g. Lambda), this is "Service".
Default is `"AWS"`.

- **`identifiers`**: *(Required `list(string)`)*
List of identifiers for principals.
When type is "AWS", these are IAM user or role ARNs.
When type is "Service", these are AWS Service roles e.g. `lambda.amazonaws.com`.

#### [`lifecycle_rules`](#main-resource-configuration) Object Arguments
See [Amazon ECR Lifecycle Policies](https://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html#lifecycle_policy_parameters)
for details.

- **`rulePriority`**: *(Optional `integer`)*
Sets the order in which rules are evaluated, lowest to highest.
A lifecycle policy rule with a priority of `1` will be acted upon first,
a rule with priority of `2` will be next, and so on.
When you add rules to a lifecycle policy,
you must give them each a unique value for `rulePriority`.
Values do not need to be sequential across rules in a policy.
A rule with a `tagStatus` value of any must have the highest value for `rulePriority` and be evaluated last.
**Note:** The AWS ECR API seems to reorder rules based on `rulePriority`.
If you define multiple rules that are not sorted in ascending `rulePriority` order in the Terraform code,
the resource will be flagged for recreation every terraform plan.

- **`description`**: *(Optional `string`)*
Describes the purpose of a rule within a lifecycle policy.

- **[`selection`](#selection-object-arguments)**: *(Optional `selection`)*
A `selection` object. For details see below.

- **[`action`](#action-object-arguments)**: *(Optional `action`)*
A `action` object. For details see below.

##### [`selection`](#lifecycle_rules-object-arguments) Object Arguments
- **`tagStatus`**: *(Required `string`)*
Determines whether the lifecycle policy rule that you are adding specifies a tag for an image.
Acceptable options are tagged, untagged, or any.
If you specify `"any"`, then all images have the rule applied to them.
If you specify `"tagged"`, then you must also specify a `tagPrefixList` value.
If you specify `"untagged"`, then you must omit `tagPrefixList`.

- **`tagPrefixList`**: *(Required `list(string)`- only if `tagStatus` is set to `"tagged"` )*
Only used if you specified `tagStatus`: `"tagged"`.
You must specify a comma-separated list of image tag prefixes on which to take action with your lifecycle policy.
For example, if your images are tagged as `prod`, `prod1`, `prod2`, and so on,
you would use the tag prefix `prod` to specify all of them.
If you specify multiple tags, only the images with all specified tags are selected.

- **`countType`**: *(Required `string`)*
Specify a count type to apply to the images.
If `countType` is set to `"imageCountMoreThan"`,
you also specify `countNumber` to create a rule that sets a limit on
the number of images that exist in your repository.
If `countType` is set to `"sinceImagePushed"`,
you also specify `countUnit` and `countNumber` to specify a time limit on
the images that exist in your repository.

- **`countUnit`**: *(Required `string` - only if `countType` is set to `"sinceImagePushed"`)*
Specify a count unit of days to indicate that as the unit of time,
in addition to `countNumber`, which is the number of days.

This should only be specified when `countType` is `"sinceImagePushed"`;
an error will occur if you specify a count unit when `countType` is any other value.

- **`countNumber`**: *(Required `number`)*
Specify a count number.
Acceptable values are positive integers (0 is not an accepted value).

If the `countType` used is `"imageCountMoreThan"`,
then the value is the maximum number of images that you want to retain in your repository.
If the `countType` used is `"sinceImagePushed"`,
then the value is the maximum age limit for your images.

##### [`action`](#lifecycle_rules-object-arguments) Object Arguments
- **`type`**: *(Required `string`)*
Specify an action type. The supported value is expire.

## Module Attributes Reference
The following attributes are exported by the module:

- **`repository`**: the original resource
[`aws_ecr_repository`](https://www.terraform.io/docs/providers/aws/r/ecr_repository.html#attributes-reference)
resource containing all arguments as specified above and the other attributes as specified below.

- **`repository_policy`**: the original resource
[`aws_ecr_repository_policy`](https://www.terraform.io/docs/providers/aws/r/ecr_repository_policy.html#attributes-reference)
resource containing all arguments as specified above and the other attributes as specified below.

- **`lifecycle_policy`**: the original resource
[`aws_ecr_lifecycle_policy`](https://www.terraform.io/docs/providers/aws/r/ecr_lifecycle_policy.html#attributes-reference)
resource containing all arguments as specified above and the other attributes as specified below.

## Module Versioning
This Module follows the principles of [Semantic Versioning (SemVer)](https://semver.org/).

Given a version number `MAJOR.MINOR.PATCH`, we increment the:
1) `MAJOR` version when we make incompatible changes,
2) `MINOR` version when we add functionality in a backwards compatible manner, and
3) `PATCH` version when we make backwards compatible bug fixes.

#### Backwards compatibility in `0.0.z` and `0.y.z` version
- Backwards compatibility in versions `0.0.z` is **not guaranteed** when `z` is increased. (Initial development)
- Backwards compatibility in versions `0.y.z` is **not guaranteed** when `y` is increased. (Pre-release)

## About Mineiros
Mineiros is a [DevOps as a Service](https://mineiros.io/) Company based in Berlin, Germany.
We offer Commercial Support for all of our projects, just send us an email to [hello@mineiros.io](mailto:hello@mineiros.io).

We can also help you with:
- Terraform Modules for all types of infrastructure such as VPC's, Docker clusters,
databases, logging and monitoring, CI, etc.
- Complex Cloud- and Multi Cloud environments.
- Consulting & Training on AWS, Terraform and DevOps.

## Reporting Issues
We use GitHub [Issues](https://github.com/mineiros-io/terraform-aws-ecr/issues)
to track community reported issues and missing features.

## Contributing
Contributions are very welcome!
We use [Pull Requests](https://github.com/mineiros-io/terraform-aws-ecr/pulls)
for accepting changes.
Please see our
[Contribution Guidelines](https://github.com/mineiros-io/terraform-aws-ecr/blob/master/CONTRIBUTING.md)
for full details.

### Makefile Targets
This repository comes with a handy
[Makefile](https://github.com/mineiros-io/terraform-aws-ecr/blob/master/Makefile).
Run `make help` to see details on each available target.

## License
This module is licensed under the Apache License Version 2.0, January 2004.
Please see [LICENSE](https://github.com/mineiros-io/terraform-aws-ecr/blob/master/LICENSE) for full details.

Copyright &copy; 2020 Mineiros
