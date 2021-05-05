# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.1] - 2020-05-05
### Added
- feat: feat: add support for Terraform v0.14.x

### Changed
- feat: upgrade terratest to v1.34.0
- build: update secrets in GitHub Actions pipeline
- build: upgrade build-tools to `v0.9.0`

## [0.2.0]
### Added
- Add support for Terraform v0.13.x
- Add support for Terraform AWS Provider v3.x
- Prepare support for Terraform v0.14.x

## [0.1.3] - 2020-07-08
### Added
- Add example and example documentation
- Add CHANGELOG.md

### Changed
- Align to latest repository structure and style

### Fixed
- Fix leaked temporary credentials (with no access)

## [0.1.2] - 2020-06-04
### Changed
- Upgrade build-tools to v0.5.3
- Upgrade pre-commit-hooks to v0.1.4
- Add phony-targets and markdown-link-check hooks
- Update documentation design

## [0.1.1] - 2020-05-04
### Fixed
- Fix a race condition in the tests for access

## [0.1.0] - 2020-03-17
### Changed
- Improve tests to test full functionality and access

## [0.0.1] - 2020-03-10
### Added
- Add ECR Repositories
- Add Repository Policies
- Add Lifecycle Policies

<!-- markdown-link-check-disable -->
[Unreleased]: https://github.com/mineiros-io/terraform-aws-ecr/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/mineiros-io/terraform-aws-ecr/compare/v0.1.3...v0.2.0
<!-- markdown-link-check-disabled -->
[0.1.3]: https://github.com/mineiros-io/terraform-aws-ecr/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/mineiros-io/terraform-aws-ecr/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/mineiros-io/terraform-aws-ecr/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/mineiros-io/terraform-aws-ecr/compare/v0.0.1...v0.1.0
[0.0.1]: https://github.com/mineiros-io/terraform-aws-ecr/releases/tag/v0.0.1
