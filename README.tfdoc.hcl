header {
  image = "https://raw.githubusercontent.com/mineiros-io/brand/3bffd30e8bdbbde32c143e2650b2faa55f1df3ea/mineiros-primary-logo.svg"
  url   = "https://mineiros.io/?ref=terraform-aws-ecr"

  badge "build" {
    image = "https://github.com/mineiros-io/terraform-aws-ecr/workflows/CI/CD%20Pipeline/badge.svg"
    url   = "https://github.com/mineiros-io/terraform-aws-ecr/actions"
    text  = "Build Status"
  }

  badge "semver" {
    image = "https://img.shields.io/github/v/tag/mineiros-io/terraform-aws-ecr.svg?label=latest&sort=semver"
    url   = "https://github.com/mineiros-io/terraform-aws-ecr/releases"
    text  = "GitHub tag (latest SemVer)"
  }

  badge "terraform" {
    image = "https://img.shields.io/badge/terraform-1.x%20|%200.15%20|%200.14%20|%200.13%20|%200.12.20+-623CE4.svg?logo=terraform"
    url   = "https://github.com/hashicorp/terraform/releases"
    text  = "Terraform Version"
  }

  badge "tf-aws-provider" {
    image = "https://img.shields.io/badge/AWS-3%20and%202.45+-F8991D.svg?logo=terraform"
    url   = "https://github.com/terraform-providers/terraform-provider-aws/releases"
    text  = "AWS Provider Version"
  }

  badge "slack" {
    image = "https://img.shields.io/badge/slack-@mineiros--community-f32752.svg?logo=slack"
    url   = "https://mineiros.io/slack"
    text  = "Join Slack"
  }
}

section {
  title   = "terraform-aws-ecr"
  toc     = true
  content = <<-END
    A [Terraform] base module for creating an
    [Amazon Elastic Container Registry Repository (ECR)][ECR] on
    [Amazon Web Services (AWS)][AWS].

    ***This module supports Terraform v1.x, v0.15, v0.14, v0.13 as well as v0.12.20 and above
    and is compatible with the Terraform AWS provider v3 as well as v2.45 and above.***
  END

  section {
    title   = "Module Features"
    content = <<-END
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
    END
  }

  section {
    title   = "Getting Started"
    content = <<-END
      Most basic usage creating an ECR repository.
      To configure aws terraform provider credentials we recommend to set the environment variables
      `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` and not configure them inside `.tf`-files
      or using terraform variables (`.tfvars` files) as those values might end up in terraforms state file
      or in github commits.

      ```hcl
      module "resource" {
        source  = "mineiros-io/ecr/aws"
        version = "~> 0.6.0"

        name = "example"
      }
      ```
    END

    section {
      title   = "Access ECR with IAM principals"
      content = <<-END
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
          version = "~> 0.6.0"

          name            = "sample-repository"
          immutable       = true
          scan_on_push    = true

          pull_identities = [module.ci-user.users["ci.github-actions-ecr"].arn]
          push_identities = [module.ci-user.users["ci.github-actions-ecr"].arn]
        }

        module "ci-user" {
          source  = "mineiros-io/iam-user/aws"
          version = "~> 0.6.0"

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
      END
    }
  }

  section {
    title   = "Module Argument Reference"
    content = <<-END
      See [variables.tf] and [examples/] for details and use-cases.
    END

    section {
      title = "Top-level Arguments"

      section {
        title = "Module Configuration"

        variable "module_enabled" {
          type        = bool
          default     = true
          description = <<-END
            Specifies whether resources in the module will be created.
          END
        }

        variable "module_tags" {
          type        = map(string)
          default     = {}
          description = <<-END
            A map of tags that will be applied to all created resources that accept tags. Tags defined with 'module_tags' can be overwritten by resource-specific tags.
          END
        }

        variable "module_depends_on" {
          type        = any
          readme_type = "list(dependencies)"
          description = <<-END
            A list of dependencies. Any object can be _assigned_ to this list to define a hidden external dependency.
          END
        }
      }

      section {
        title = "Main Resource Configuration"

        variable "name" {
          required    = true
          type        = string
          description = <<-END
            The name of the repository. Forces new resource.
          END
        }

        variable "immutable" {
          type        = string
          default     = "false"
          description = <<-END
            You can configure a repository to be immutable to prevent image tags from being overwritten.
          END
        }

        variable "tags" {
          type        = map(string)
          default     = {}
          description = <<-END
            A mapping of tags to assign to the `aws_ecr_repository` resources.
          END
        }

        variable "scan_on_push" {
          type        = map(string)
          default     = true
          description = <<-END
            Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false).
          END
        }
      }

      section {
        title = "Extended Resource configuration"

        variable "repository_policy_statements" {
          type        = any
          readme_type = "list(policy_statements)"
          default     = []
          description = <<-END
            List of statements of the repository policy.
          END

          attribute "sid" {
            type        = string
            description = <<-END
              An ID for the policy statement.
            END
          }

          attribute "effect" {
            type        = string
            default     = "Allow"
            description = <<-END
              Either "Allow" or "Deny", to specify whether this statement allows or denies the given actions.
            END
          }

          attribute "actions" {
            type        = list(string)
            description = <<-END
              A list of actions that this statement either allows or denies.
            END
          }

          attribute "not_actions" {
            type        = list(string)
            description = <<-END
              A list of actions that this statement does not apply to.
              Used to apply a policy statement to all actions except those listed.
            END
          }

          attribute "principals" {
            type        = any
            readme_type = "list(principal)"
            description = <<-END
              A nested configuration block (described below) specifying a resource (or resource pattern) to which this statement applies.
            END

            attribute "type" {
              type        = string
              default     = "AWS"
              description = <<-END
                The type of principal. For AWS ARNs this is "AWS". For AWS services (e.g. Lambda), this is "Service".
              END
            }

            attribute "identifiers" {
              required    = true
              type        = list(string)
              description = <<-END
                List of identifiers for principals.
                When type is "AWS", these are IAM user or role ARNs.
                When type is "Service", these are AWS Service roles e.g. `lambda.amazonaws.com`.
              END
            }
          }

          attribute "not_principals" {
            type        = any
            readme_type = "list(principal)"
            description = <<-END
              Like principals except gives resources that the statement does not apply to.
            END
          }
        }

        variable "lifecycle_policy_rules" {
          type        = any
          readme_type = "list(lifecycle_policy_rules)"
          default     = []
          description = <<-END
            List of lifecycle policy rules.
          END

          attribute "rulePriority" {
            type        = any
            readme_type = "integer"
            description = <<-END
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
            END
          }

          attribute "description" {
            type        = string
            description = <<-END
              Describes the purpose of a rule within a lifecycle policy.
            END
          }

          attribute "selection" {
            type        = any
            readme_type = "selection"
            description = <<-END
              A `selection` object.
            END

            attribute "tagStatus" {
              required    = true
              type        = string
              description = <<-END
                Determines whether the lifecycle policy rule that you are adding specifies a tag for an image.
                Acceptable options are tagged, untagged, or any.
                If you specify `"any"`, then all images have the rule applied to them.
                If you specify `"tagged"`, then you must also specify a `tagPrefixList` value.
                If you specify `"untagged"`, then you must omit `tagPrefixList`.
              END
            }

            attribute "tagPrefixList" {
              required    = true
              type        = list(string)
              description = <<-END
                Only used if you specified `tagStatus`: `"tagged"`.
                You must specify a comma-separated list of image tag prefixes on which to take action with your lifecycle policy.
                For example, if your images are tagged as `prod`, `prod1`, `prod2`, and so on,
                you would use the tag prefix `prod` to specify all of them.
                If you specify multiple tags, only the images with all specified tags are selected.
              END
            }

            attribute "countType" {
              required    = true
              type        = string
              description = <<-END
                Specify a count type to apply to the images.
                If `countType` is set to `"imageCountMoreThan"`,
                you also specify `countNumber` to create a rule that sets a limit on
                the number of images that exist in your repository.
                If `countType` is set to `"sinceImagePushed"`,
                you also specify `countUnit` and `countNumber` to specify a time limit on
                the images that exist in your repository.
              END
            }

            attribute "countUnit" {
              required    = true
              type        = string
              description = <<-END
                Specify a count unit of days to indicate that as the unit of time, in addition to `countNumber`, which is the number of days.

                This should only be specified when `countType` is `"sinceImagePushed"`;
                an error will occur if you specify a count unit when `countType` is any other value.
              END
            }

            attribute "countNumber" {
              required    = true
              type        = number
              description = <<-END
                Specify a count number.
                Acceptable values are positive integers (0 is not an accepted value).

                If the `countType` used is `"imageCountMoreThan"`,
                then the value is the maximum number of images that you want to retain in your repository.
                If the `countType` used is `"sinceImagePushed"`,
                then the value is the maximum age limit for your images.
              END
            }
          }

          attribute "action" {
            type        = any
            readme_type = "action"
            description = <<-END
              An `action` object.
            END

            attribute "type" {
              required    = true
              type        = string
              description = <<-END
                Specify an action type. The supported value is expire.
              END
            }
          }
        }
      }

      section {
        title = "Additional configuration"

        variable "pull_identities" {
          type        = list(string)
          default     = []
          description = <<-END
            List of AWS identity identifiers to grant cross account pull access to.
          END
        }

        variable "push_identities" {
          type        = list(string)
          default     = []
          description = <<-END
            List of AWS identity identifiers to grant cross account push access to.
          END
        }
      }
    }
  }

  section {
    title   = "Module Outputs"
    content = <<-END
      The following attributes are exported by the module:

      - **`repository`**

        The original resource [`aws_ecr_repository`] resource.

      - **`repository_policy`**

        The original resource [`aws_ecr_repository_policy`] resource.

      - **`lifecycle_policy`**

        The original resource [`aws_ecr_lifecycle_policy`] resource.
    END
  }

  section {
    title = "External Documentation"

    section {
      title   = "AWS Documentation IAM"
      content = <<-END
        - Repositories: https://docs.aws.amazon.com/AmazonECR/latest/userguide/Repositories.html
        - IAM Access: https://docs.aws.amazon.com/AmazonECR/latest/userguide/security-iam.html
        - Lifecycle Policies: https://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html
      END
    }

    section {
      title   = "Terraform AWS Provider Documentation"
      content = <<-END
        - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository
        - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy
        - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy
      END
    }
  }

  section {
    title   = "Module Versioning"
    content = <<-END
      This Module follows the principles of [Semantic Versioning (SemVer)].

      Given a version number `MAJOR.MINOR.PATCH`, we increment the:

      1. `MAJOR` version when we make incompatible changes,
      2. `MINOR` version when we add functionality in a backwards compatible manner, and
      3. `PATCH` version when we make backwards compatible bug fixes.
    END

    section {
      title   = "Backwards compatibility in `0.0.z` and `0.y.z` version"
      content = <<-END
        - Backwards compatibility in versions `0.0.z` is **not guaranteed** when `z` is increased. (Initial development)
        - Backwards compatibility in versions `0.y.z` is **not guaranteed** when `y` is increased. (Pre-release)
      END
    }
  }

  section {
    title   = "About Mineiros"
    content = <<-END
      Mineiros is a [DevOps as a Service][homepage] company based in Berlin, Germany.
      We offer commercial support for all of our projects and encourage you to reach out
      if you have any questions or need help. Feel free to send us an email at [hello@mineiros.io] or join our [Community Slack channel][slack].

      We can also help you with:

      - Terraform modules for all types of infrastructure such as VPCs, Docker clusters, databases, logging and monitoring, CI, etc.
      - Consulting & training on AWS, Terraform and DevOps
    END
  }

  section {
    title   = "Reporting Issues"
    content = <<-END
      We use GitHub [Issues] to track community reported issues and missing features.
    END
  }

  section {
    title   = "Contributing"
    content = <<-END
      Contributions are always encouraged and welcome! For the process of accepting changes, we use
      [Pull Requests]. If you'd like more information, please see our [Contribution Guidelines].
    END
  }

  section {
    title   = "Makefile Targets"
    content = <<-END
      This repository comes with a handy [Makefile].
      Run `make help` to see details on each available target.
    END
  }

  section {
    title   = "License"
    content = <<-END
      [![license][badge-license]][apache20]

      This module is licensed under the Apache License Version 2.0, January 2004.
      Please see [LICENSE] for full details.

      Copyright &copy; 2020-2022 [Mineiros GmbH][homepage]
    END
  }
}

references {
  ref "ECR" {
    value = "https://aws.amazon.com/ecr/"
  }
  ref "Amazon ECR Lifecycle Policies" {
    value = "https://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html"
  }
  ref "`aws_ecr_repository`" {
    value = "https://www.terraform.io/docs/providers/aws/r/ecr_repository.html#attributes-reference"
  }
  ref "`aws_ecr_repository_policy`" {
    value = "https://www.terraform.io/docs/providers/aws/r/ecr_repository_policy.html#attributes-reference"
  }
  ref "`aws_ecr_lifecycle_policy`" {
    value = "https://www.terraform.io/docs/providers/aws/r/ecr_lifecycle_policy.html#attributes-reference"
  }
  ref "badge-tf-aws" {
    value = "https://img.shields.io/badge/AWS-3%20and%202.45+-F8991D.svg?logo=terraform"
  }
  ref "releases-aws-provider" {
    value = "https://github.com/terraform-providers/terraform-provider-aws/releases"
  }
  ref "homepage" {
    value = "https://mineiros.io/?ref=terraform-aws-ecr"
  }
  ref "hello@mineiros.io" {
    value = "mailto:hello@mineiros.io"
  }
  ref "badge-build" {
    value = "https://github.com/mineiros-io/terraform-aws-ecr/workflows/CI/CD%20Pipeline/badge.svg"
  }
  ref "badge-semver" {
    value = "https://img.shields.io/github/v/tag/mineiros-io/terraform-aws-ecr.svg?label=latest&sort=semver"
  }
  ref "badge-license" {
    value = "https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg"
  }
  ref "badge-terraform" {
    value = "https://img.shields.io/badge/terraform-1.x%20|%200.15%20|%200.14%20|%200.13%20|%200.12.20+-623CE4.svg?logo=terraform"
  }
  ref "badge-slack" {
    value = "https://img.shields.io/badge/slack-@mineiros--community-f32752.svg?logo=slack"
  }
  ref "build-status" {
    value = "https://github.com/mineiros-io/terraform-aws-ecr/actions"
  }
  ref "releases-github" {
    value = "https://github.com/mineiros-io/terraform-aws-ecr/releases"
  }
  ref "releases-terraform" {
    value = "https://github.com/hashicorp/terraform/releases"
  }
  ref "apache20" {
    value = "https://opensource.org/licenses/Apache-2.0"
  }
  ref "slack" {
    value = "https://join.slack.com/t/mineiros-community/shared_invite/zt-ehidestg-aLGoIENLVs6tvwJ11w9WGg"
  }
  ref "Terraform" {
    value = "https://www.terraform.io"
  }
  ref "AWS" {
    value = "https://aws.amazon.com/"
  }
  ref "Semantic Versioning (SemVer)" {
    value = "https://semver.org/"
  }
  ref "variables.tf" {
    value = "https://github.com/mineiros-io/terraform-aws-ecr/blob/master/variables.tf"
  }
  ref "examples/" {
    value = "https://github.com/mineiros-io/terraform-aws-ecr/blob/master/examples"
  }
  ref "Issues" {
    value = "https://github.com/mineiros-io/terraform-aws-ecr/issues"
  }
  ref "LICENSE" {
    value = "https://github.com/mineiros-io/terraform-aws-ecr/blob/master/LICENSE"
  }
  ref "Makefile" {
    value = "https://github.com/mineiros-io/terraform-aws-ecr/blob/master/Makefile"
  }
  ref "Pull Requests" {
    value = "https://github.com/mineiros-io/terraform-aws-ecr/pulls"
  }
  ref "Contribution Guidelines" {
    value = "https://github.com/mineiros-io/terraform-aws-ecr/blob/master/CONTRIBUTING.md"
  }
}
