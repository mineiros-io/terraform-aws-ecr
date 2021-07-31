[<img src="https://raw.githubusercontent.com/mineiros-io/brand/3bffd30e8bdbbde32c143e2650b2faa55f1df3ea/mineiros-primary-logo.svg" width="400"/>][homepage]

[![Build Status][badge-build]][build-status]
[![GitHub tag (latest SemVer)][badge-semver]][releases-github]
[![Terraform Version][badge-terraform]][releases-terraform]
[![AWS Provider Version][badge-tf-aws]][releases-aws-provider]
[![Join Slack][badge-slack]][slack]

# terraform-aws-ecr

A [Terraform] base module for creating an
[Amazon Elastic Container Registry Repository (ECR)][ECR] on
[Amazon Web Services (AWS)][AWS].

***This module supports Terraform v0.14, v0.13 as well as v0.12.20 and above
and is compatible with the Terraform AWS provider v3 as well as v2.45 and above.***

- [Module Features](#module-features)
- [Getting Started](#getting-started)
- [Module Argument Reference](#module-argument-reference)
  - [Top-level Arguments](#top-level-arguments)
    - [Main Resource Configuration](#main-resource-configuration)
    - [Extended Resource configuration](#extended-resource-configuration)
    - [Additional configuration](#additional-configuration)
    - [`policy_statements` Object Arguments](#policy_statements-object-arguments)
    - [`principal` Object Arguments](#principal-object-arguments)
    - [`lifecycle_rules` Object Arguments](#lifecycle_rules-object-arguments)
    - [`selection` Object Arguments](#selection-object-arguments)
    - [`action` Object Arguments](#action-object-arguments)
- [Module Attributes Reference](#module-attributes-reference)
- [External Documentation](#external-documentation)
- [Module Versioning](#module-versioning)
  - [Backwards compatibility in `0.0.z` and `0.y.z` version](#backwards-compatibility-in-00z-and-0yz-version)
- [About Mineiros](#about-mineiros)
- [Reporting Issues](#reporting-issues)
- [Contributing](#contributing)
- [Makefile Targets](#makefile-targets)
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
  Grant pull & push access to AWS identities (cross account),
  Grant pull & push & ECR authentication access to AWS accounts (cross account)

- *Features not yet implemented*:
  Easy lifecycle rule setup

## Getting Started

Most basic usage creating an ECR repository.
To configure aws terraform provider credentials we recommend to set the environment variables
`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` and not configure them inside `.tf`-files
or using terraform variables (`.tfvars` files) as those values might end up in terraforms state file
or in github commits.

```hcl
module "resource" {
  source  = "mineiros-io/ecr/aws"
  version = "~> 0.4.0"

  name = "example"
}
```

### Access ECR with IAM principals

If you'd like to pull and push images from and to the registry with IAM
principals such as an IAM user, you will need to request an authorization token
that is used to access any Amazon ECR registry that your IAM principal has
access to and is valid for 12 hours. To obtain an authorization token, you
must use the GetAuthorizationToken API operation to retrieve a base64-encoded
authorization token containing the username AWS and an encoded password. 

Since `ecr:GetAuthorizationToken` does not support resource-level permissions,
you'll need to grant `"Resource": "*"` to the `ecr:GetAuthorizationToken` action
for every principal that should have access.

Please note, that since this module does not handle the `ecr:GetAuthorizationToken`
permission for you, it needs to be granted for principals on an individual basis.

Please consider the following example to grant pull and push permissions to an
IAM user.

```hcl
module "ecr" {
  source  = "mineiros-io/ecr/aws"
  version = "~> 0.4.0"

  name            = "sample-repository"
  immutable       = true
  scan_on_push    = true

  pull_identities = [module.ci-user.users["ci.github-actions-ecr"].arn]
  push_identities = [module.ci-user.users["ci.github-actions-ecr"].arn]
}

module "ci-user" {
  source  = "mineiros-io/iam-user/aws"
  version = "~> 0.4.0"

  names = ["ci.github-actions-ecr"]

  policy_statements = [
    {
      sid = "GetAuthorizationToken"
      effect    = "Allow"
      actions   = ["ecr:GetAuthorizationToken"]
      resources = ["*"]
    }
  ]
}
```

## Module Argument Reference

See [variables.tf] and [examples/] for details and use-cases.

### Top-level Arguments

#### Module Configuration

- **`module_enabled`**: _(Optional `bool`)_

  Specifies whether resources in the module will be created.
  Default is `true`.

- **`module_tags`**: _(Optional `map(string)`)_

  A map of tags that will be applied to all created resources that accept tags. Tags defined with 'module_tags' can be
  overwritten by resource-specific tags.
  Default is `{}`.

- **`module_depends_on`**: _(Optional `list(dependencies)`)_

  A list of dependencies. Any object can be _assigned_ to this list to define a hidden external dependency.

#### Main Resource Configuration

- **`name`**: **(Required `string`, Forces new resource)**

  The name of the repository.

- **`immutable`**: *(Optional `string`)*

  You can configure a repository to be immutable to prevent image tags from being overwritten.
  Defaults to `false`.

- **`tags`**: *(Optional `map(string)`)*

  A mapping of tags to assign to the `aws_ecr_repository` resources.
  Defaults to `{}`.

- **`scan_on_push`**: *(Optional `map(string)`)*

  Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false).
  Defaults to `false`.

#### Extended Resource configuration

- **[`repository_policy_statements`](#policy_statement-object-arguments)**: *(Optional `list(policy_statements)`)*

  List of statements of the repository policy.
  Default is `[]`.

- **[`repository_lifecycle_rules`](#lifecycle_rule-object-arguments)**: *(Optional `list(lifecycle_rules)`)*

  List of lifecycle policy rules.
  Default is `[]`.

#### Additional configuration

- **`pull_identities`**: *(Optional `list(string)`)*

  List of AWS identity identifiers to grant cross account pull access to.
  Default is `[]`.

- **`push_identities`**: *(Optional `list(string)`)*

  List of AWS identity identifiers to grant cross account push access to.
  Default is `[]`.

- **`pull_accounts`**: *(Optional `list(string)`)*

  List of AWS Account IDs to grant cross account pull access and
  authentication access with ECR to.
  Default is `[]`.

- **`push_accounts`**: *(Optional `list(string)`)*

  List of AWS Account IDs to grant cross account push access and
  authentication access with ECR to.
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

#### [`principal`](#policy_statement-object-arguments) Object Arguments

- **`type`**: *(Optional `string`)*

  The type of principal. For AWS ARNs this is "AWS". For AWS services (e.g. Lambda), this is "Service".
  Default is `"AWS"`.

- **`identifiers`**: *(Required `list(string)`)*

  List of identifiers for principals.
  When type is "AWS", these are IAM user or role ARNs.
  When type is "Service", these are AWS Service roles e.g. `lambda.amazonaws.com`.

#### [`lifecycle_rules`](#main-resource-configuration) Object Arguments

See [Amazon ECR Lifecycle Policies] for details.

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

#### [`selection`](#lifecycle_rules-object-arguments) Object Arguments

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

#### [`action`](#lifecycle_rules-object-arguments) Object Arguments

- **`type`**: *(Required `string`)*

  Specify an action type. The supported value is expire.

## Module Attributes Reference

The following attributes are exported by the module:

- **`repository`**

  The original resource [`aws_ecr_repository`] resource.

- **`repository_policy`**

  The original resource [`aws_ecr_repository_policy`] resource.

- **`lifecycle_policy`**

  The original resource [`aws_ecr_lifecycle_policy`] resource.

## External Documentation

- AWS Documentation IAM:
  - Repositories: https://docs.aws.amazon.com/AmazonECR/latest/userguide/Repositories.html
  - IAM Access: https://docs.aws.amazon.com/AmazonECR/latest/userguide/security-iam.html
  - Lifecycle Policies: https://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html

- Terraform AWS Provider Documentation:
  - https://www.terraform.io/docs/providers/aws/r/ecr_repository.html
  - https://www.terraform.io/docs/providers/aws/r/ecr_repository_policy.html
  - https://www.terraform.io/docs/providers/aws/r/ecr_lifecycle_policy.html

## Module Versioning

This Module follows the principles of [Semantic Versioning (SemVer)].

Given a version number `MAJOR.MINOR.PATCH`, we increment the:

1. `MAJOR` version when we make incompatible changes,
2. `MINOR` version when we add functionality in a backwards compatible manner, and
3. `PATCH` version when we make backwards compatible bug fixes.

### Backwards compatibility in `0.0.z` and `0.y.z` version

- Backwards compatibility in versions `0.0.z` is **not guaranteed** when `z` is increased. (Initial development)
- Backwards compatibility in versions `0.y.z` is **not guaranteed** when `y` is increased. (Pre-release)

## About Mineiros

Mineiros is a [DevOps as a Service][homepage] company based in Berlin, Germany.
We offer commercial support for all of our projects and encourage you to reach out
if you have any questions or need help. Feel free to send us an email at [hello@mineiros.io] or join our [Community Slack channel][slack].

We can also help you with:

- Terraform modules for all types of infrastructure such as VPCs, Docker clusters, databases, logging and monitoring, CI, etc.
- Consulting & training on AWS, Terraform and DevOps

## Reporting Issues

We use GitHub [Issues] to track community reported issues and missing features.

## Contributing

Contributions are always encouraged and welcome! For the process of accepting changes, we use
[Pull Requests]. If you'd like more information, please see our [Contribution Guidelines].

## Makefile Targets

This repository comes with a handy [Makefile].
Run `make help` to see details on each available target.

## License

[![license][badge-license]][apache20]

This module is licensed under the Apache License Version 2.0, January 2004.
Please see [LICENSE] for full details.

Copyright &copy; 2021 [Mineiros GmbH][homepage]

<!-- References -->

[ECR]: https://aws.amazon.com/ecr/
[Amazon ECR Lifecycle Policies]: https://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html

[`aws_ecr_repository`]: https://www.terraform.io/docs/providers/aws/r/ecr_repository.html#attributes-reference
[`aws_ecr_repository_policy`]: https://www.terraform.io/docs/providers/aws/r/ecr_repository_policy.html#attributes-reference
[`aws_ecr_lifecycle_policy`]: https://www.terraform.io/docs/providers/aws/r/ecr_lifecycle_policy.html#attributes-reference

[badge-tf-aws]: https://img.shields.io/badge/AWS-3%20and%202.45+-F8991D.svg?logo=terraform
[releases-aws-provider]: https://github.com/terraform-providers/terraform-provider-aws/releases

[homepage]: https://mineiros.io/?ref=terraform-aws-ecr
[hello@mineiros.io]: mailto:hello@mineiros.io

[badge-build]: https://github.com/mineiros-io/terraform-aws-ecr/workflows/CI/CD%20Pipeline/badge.svg
[badge-semver]: https://img.shields.io/github/v/tag/mineiros-io/terraform-aws-ecr.svg?label=latest&sort=semver
[badge-license]: https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg
[badge-terraform]: https://img.shields.io/badge/terraform-0.15%20|%200.14%20|%200.13%20|%200.12.20+-623CE4.svg?logo=terraform
[badge-slack]: https://img.shields.io/badge/slack-@mineiros--community-f32752.svg?logo=slack

[build-status]: https://github.com/mineiros-io/terraform-aws-ecr/actions
[releases-github]: https://github.com/mineiros-io/terraform-aws-ecr/releases
[releases-terraform]: https://github.com/hashicorp/terraform/releases
[apache20]: https://opensource.org/licenses/Apache-2.0
[slack]: https://join.slack.com/t/mineiros-community/shared_invite/zt-ehidestg-aLGoIENLVs6tvwJ11w9WGg

[Terraform]: https://www.terraform.io
[AWS]: https://aws.amazon.com/
[Semantic Versioning (SemVer)]: https://semver.org/

[variables.tf]: https://github.com/mineiros-io/terraform-aws-ecr/blob/master/variables.tf
[examples/]: https://github.com/mineiros-io/terraform-aws-ecr/blob/master/examples
[Issues]: https://github.com/mineiros-io/terraform-aws-ecr/issues
[LICENSE]: https://github.com/mineiros-io/terraform-aws-ecr/blob/master/LICENSE
[Makefile]: https://github.com/mineiros-io/terraform-aws-ecr/blob/master/Makefile
[Pull Requests]: https://github.com/mineiros-io/terraform-aws-ecr/pulls
[Contribution Guidelines]: https://github.com/mineiros-io/terraform-aws-ecr/blob/master/CONTRIBUTING.md
