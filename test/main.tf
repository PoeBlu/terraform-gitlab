locals {
  ssh_private_key_path = "~/.ssh/brotandgames_automation_id_rsa"
  fqdn                 = "gitlab.yourhost.com"
  ssh_host             = "192.168.1.100"
}

module "gitlab" {
  source = "../"

  ssh_host             = local.ssh_host
  ssh_user             = "root"
  ssh_private_key_path = local.ssh_private_key_path

  gitlab_docker_repo      = "gitlab-ce"
  gitlab_docker_tag       = "12.4.1-ce.0"
  gitlab_external_url     = "https://${local.fqdn}"
  gitlab_config_rb        = <<CONFIG
# TODO
# [ ] external_url set twice in module input
external_url 'https://${local.fqdn}'
gitlab_rails['gitlab_email_display_name'] = 'GitLab [yourhost]'
gitlab_rails['gitlab_email_from'] = 'noreply@yourhost.net'

letsencrypt['enable'] = true # GitLab 10.5 and 10.6 require this option
letsencrypt['contact_emails'] = ['support@yourhost.net']
CONFIG
  gitlab_data_path        = "/mnt/gitlab-data-1/gitlab"
  gitlab_runner_data_path = "/mnt/gitlab-data-1/gitlab-runner"
}
