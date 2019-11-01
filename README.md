# terraform-gitlab

Terraform Module to deploy GitLab on a node with SSH access using Docker

## Usage

See `test/main.tf` for example usage of the module.

### Where to go further?

tbd.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| gitlab\_config\_rb | GitLab settings (gitlab.rb) | string | `""` | no |
| gitlab\_docker\_repo | GitLab Docker repo - check https://hub.docker.com/u/gitlab | string | `"gitlab-ce"` | no |
| gitlab\_docker\_tag | GitLab Docker tag (version) - check https://hub.docker.com/u/gitlab | string | `"12.4.1-ce.0"` | no |
| gitlab\_external\_url | GitLab external url | string | `""` | no |
| ssh\_host | SSH host | string | `"192.168.0.100"` | no |
| ssh\_private\_key\_path | SSH private key path | string | `"~/.ssh/id_rsa"` | no |
| ssh\_user | SSH user | string | `"root"` | no |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Contributing

We encourage you to contribute to this project in whatever way you like!

## Versioning

[Semantic Versioning 2.x](https://semver.org/)

In a nutshell:

> Given a version number MAJOR.MINOR.PATCH, increment the:
>
> 1. MAJOR version when you make incompatible API changes,
> 2. MINOR version when you add functionality in a backwards-compatible manner, and
> 3. PATCH version when you make backwards-compatible bug fixes.
>
> Additional labels for pre-release and build metadata are available as extensions to the MAJOR.MINOR.PATCH format.

## Maintainer

https://github.com/brotandgames


