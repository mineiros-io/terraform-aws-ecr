<img src="https://i.imgur.com/t8IkKoZl.png" width="200"/>

[![Maintained by Mineiros.io](https://img.shields.io/badge/maintained%20by-mineiros.io-00607c.svg)](https://www.mineiros.io/ref=terraform-module-template)
[![Build Status](https://mineiros.semaphoreci.com/badges/terraform-module-template/branches/master.svg?style=shields)](https://mineiros.semaphoreci.com/projects/terraform-module-template)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/mineiros-io/terraform-module-template.svg?label=latest&sort=semver)](https://github.com/mineiros-io/terraform-module-template/releases)
[![Terraform Version](https://img.shields.io/badge/terraform-~%3E%200.12.20-brightgreen.svg)](https://github.com/hashicorp/terraform/releases)
[![License](https://img.shields.io/badge/License-Apache%202.0-brightgreen.svg)](https://opensource.org/licenses/Apache-2.0)

# terraform-module-template
A [Terraform](https://www.terraform.io) 0.12 base module for
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
In contrast to the plain `terraform_resource` resource this module has better features.
While all security features can be disabled as needed best practices
are pre-configured.

In addition to cool features we also have awesome features.

- **Default Security Settings**:
  Secure by default by setting security to `true`,
  Additional security addedy setting some feature to `enabeled`.

- **Standard Module Features**:
  Cool Feature of the main resource,
  Tags

- **Extended Module Features**:
  Awesome extended feature of an additional related resource,
  And another cool feature

- **Additional Features**:
  A cool feature that is not actually a resource but a cool set up from us

- *Features not yet implemented*:
  Standard features missing,
  Extended features planned,
  Additional features planned

## Getting Started
Most basic usage creating a random named secure AWS bucket.

```hcl
module "resource" {
  source  = "mineiros-io/resource/provider"
  version = "0.0.0"
}
```

## Module Argument Reference
See
[variables.tf](https://github.com/mineiros-io/terraform-module-template/blob/master/variables.tf)
and
[examples/](https://github.com/mineiros-io/terraform-module-template/blob/master/examples)
for details and use-cases.

#### Top-level Arguments

##### Main Resource Configuration
- **`create`**: *(Optional `bool`)*
Specifies whether the bucket should be created.
Default is `true`.

- **`name`**: *(Optional `string`, Forces new resource)*
The name of the resource. If omitted, Terraform will assign a random, unique name.

- **`argument`**: **(Required `string`)**
A required argument.

- **[`some_block`](#some_block-object-arguments)**: *(Optional `object`)*
Specifies a block with some attributes.
Default is `{}`.

##### Extended Resource configuration
- **`extended_argument`**: *(Optional `bool`)*
when set this argument forces the following behaviour:
  - `TRAFFIC_LIGHT` is always `green`
  - `WEATHER` is always `sunny`

#### [`some_block`](#main-resource-configuration) Object Arguments
- **`block_argument`**: *(Optional `list(string)`)*
cool argument inside of a block to enable stuff.
Default is `[]`.

## Module Attributes Reference
The following attributes are exported by the module:

- **`resource`**: the original resource
[`some_resource` resource](https://www.terraform.io/docs/providers/provider/r/some#attributes-reference)
containing all arguments as specified above and the other attributes as specified below.
- **`create`**: The `create` argument.

## Module Versioning
This Module follows the principles of [Semantic Versioning (SemVer)](https://semver.org/).

Using the given version number of `MAJOR.MINOR.PATCH`, we apply the following constructs:
1) Use the `MAJOR` version for incompatible changes.
2) Use the `MINOR` version when adding functionality in a backwards compatible manner.
3) Use the `PATCH` version when introducing backwards compatible bug fixes.

### Backwards compatibility in `0.0.z` and `0.y.z` version
- In the context of initial development, backwards compatibility in versions `0.0.z` is **not guaranteed** when `z` is 
  increased. (Initial development)
- In the context of pre-release, backwards compatibility in versions `0.y.z` is **not guaranteed** when `y` is
increased. (Pre-release)

## About Mineiros
Mineiros is a [DevOps as a Service](https://mineiros.io/) company based in Berlin, Germany. We offer commercial support
for all of our projects and encourage you to reach out if you have any questions or need help.
Feel free to send us an email at [hello@mineiros.io](mailto:hello@mineiros.io).

We can also help you with:
- Terraform Modules for all types of infrastructure such as VPC's, Docker clusters,
databases, logging and monitoring, CI, etc.
- Consulting & Training on AWS, Terraform and DevOps.

## Reporting Issues
We use GitHub [Issues](https://github.com/mineiros-io/terraform-module-template/issues)
to track community reported issues and missing features.

## Contributing
Contributions are always encouraged and welcome! For the process of accepting changes, we use
[Pull Requests](https://github.com/mineiros-io/terraform-module-template/pulls). If you’d like more information, please
see our [Contribution Guidelines](https://github.com/mineiros-io/terraform-module-template/blob/master/CONTRIBUTING.md).

## Makefile Targets
This repository comes with a handy
[Makefile](https://github.com/mineiros-io/terraform-module-template/blob/master/Makefile).  
Run `make help` to see details on each available target.

## License
This module is licensed under the Apache License Version 2.0, January 2004.
Please see [LICENSE](https://github.com/mineiros-io/terraform-module-template/blob/master/LICENSE) for full details.

Copyright &copy; 2020 Mineiros
