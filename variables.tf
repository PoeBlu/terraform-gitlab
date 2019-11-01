variable "ssh_private_key_path" {
  description = "SSH private key path"
  default     = "~/.ssh/id_rsa"
}

variable "ssh_user" {
  description = "SSH user"
  default     = "root"
}

variable "ssh_host" {
  description = "SSH host"
  default     = "192.168.0.100"
}

variable "gitlab_docker_repo" {
  description = "GitLab Docker repo - check https://hub.docker.com/u/gitlab"
  default     = "gitlab-ce"
}

variable "gitlab_docker_tag" {
  description = "GitLab Docker tag (version) - check https://hub.docker.com/u/gitlab"
  default     = "12.4.1-ce.0"
}

variable "gitlab_external_url" {
  description = "GitLab external url"
  default     = ""
}

variable "gitlab_config_rb" {
  description = "GitLab settings (gitlab.rb)"
  default     = ""
}

variable "gitlab_data_path" {
  description = "GitLab absolute path to GitLab data"
  default     = "/srv/gitlab"
}

variable "gitlab_runner_data_path" {
  description = "GitLab absolute path to GitLab Runner data"
  default     = "/srv/gitlab-runner"
}
