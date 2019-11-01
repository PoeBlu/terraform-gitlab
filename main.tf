resource "null_resource" "install" {

  triggers = {
    gitlab_docker_repo  = md5(var.gitlab_docker_repo)
    gitlab_docker_tag   = md5(var.gitlab_docker_tag)
    gitlab_external_url = md5(var.gitlab_external_url)
    gitlab_config_rb    = md5(var.gitlab_config_rb)
  }

  connection {
    type        = "ssh"
    user        = var.ssh_user
    host        = var.ssh_host
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "file" {
    source      = "${path.module}/files/install.sh"
    destination = "/tmp/install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install.sh",
      "/tmp/install.sh ${var.gitlab_docker_repo} ${var.gitlab_docker_tag} ${var.gitlab_external_url} \"${var.gitlab_config_rb}\""
    ]
  }

}
