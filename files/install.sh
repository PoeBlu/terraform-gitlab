#!/usr/bin/env bash
#
# id: bash_install_gitlab_docker
# description: Install GitLab using Docker in an idempotent way
#
# Resources
# - GitLab Omnibus Docker Documentation: https://docs.gitlab.com/omnibus/docker/
#

set -e

self=${0##*/}
log() {
  echo "== $self $1"
}

GITLAB_DOCKER_REPO="$1"
GITLAB_DOCKER_TAG="$2"
GITLAB_EXTERNAL_URL="$3"
GITLAB_CONFIG_RB="$4"

[ "$(docker ps -a | grep gitlab)" ] && docker stop gitlab && docker rm gitlab

log "GITLAB_DOCKER_REPO=$GITLAB_DOCKER_REPO"
log "GITLAB_DOCKER_TAG=$GITLAB_DOCKER_TAG"
log "GITLAB_EXTERNAL_URL=$GITLAB_EXTERNAL_URL"
log "GITLAB_CONFIG_RB=$GITLAB_CONFIG_RB"

GITLAB_DATA_PATH="/srv/gitlab"
GITLAB_RUNNER_DATA_PATH="/srv/gitlab-runner"
log "GITLAB_DATA_PATH=$GITLAB_DATA_PATH"
log "GITLAB_RUNNER_DATA_ROOT_PATH=$GITLAB_RUNNER_DATA_PATH"

log "Install prerequisites ..."
sudo apt-get update -qq >/dev/null
sudo apt-get install -qq -y apt-transport-https

log "Install docker ..."
wget -nv -O - https://get.docker.com/ | sh

log "Create volume directories ..."
mkdir -p $GITLAB_DATA_PATH/config
mkdir -p $GITLAB_DATA_PATH/data
mkdir -p /var/log/gitlab

log "Write gitlab.rb to $GITLAB_DATA_PATH/config/gitlab.rb ..."
echo "$GITLAB_CONFIG_RB" > $GITLAB_DATA_PATH/config/gitlab.rb

log "Run docker container (detached) ..."
docker run --detach \
  --restart unless-stopped \
  --name gitlab \
  --publish 80:80 \
  --publish 443:443 \
  --publish 5000:5000 \
  --publish 9022:22 \
  --volume $GITLAB_DATA_PATH/data:/var/opt/gitlab \
  --volume $GITLAB_DATA_PATH/config:/etc/gitlab \
  --volume /var/log/gitlab:/var/log/gitlab \
  gitlab/${GITLAB_DOCKER_REPO}:${GITLAB_DOCKER_TAG}

# TODO
# [ ] Backup volume $BACKUP_FOLDER
# Add GitLab backup job to crontab
# Backup, upload to S3 or S3 compatible storage and leave 2 (newest) backups in $BACKUP_FOLDER
# (crontab -l ; echo "00 02 * * * /usr/bin/docker exec gitlab gitlab-rake gitlab:backup:create STRATEGY=copy CRON=1 && cd $BACKUP_FOLDER && ls -t | tail -n +3 | xargs --no-run-if-empty rm --") | crontab -

log "Installing GitLab Runner ..."

[ "$(docker ps -a | grep gitlab-runner)" ] && docker stop gitlab-runner && docker rm gitlab-runner

mkdir -p $GITLAB_RUNNER_DATA_PATH/config

docker run --detach \
  --name gitlab-runner \
  --restart unless-stopped \
  --volume $GITLAB_RUNNER_DATA_PATH/config:/etc/gitlab-runner \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  gitlab/gitlab-runner:latest

cat > $GITLAB_RUNNER_DATA_PATH/config/config.toml <<- EOF
concurrent = 2
check_interval = 5
EOF

# When the scheme of external_url is https it's not possible
# to register the runner with the internal docker ip of GitLab
#
# GITLAB_DOCKER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' gitlab)
# log "GITLAB_DOCKER_IP=$GITLAB_DOCKER_IP"
# log "Waiting for GitLab on $GITLAB_DOCKER_IP ..."
# while ! curl -sSf "http://${GITLAB_DOCKER_IP}/-/readiness" > /dev/null; do sleep 5; done;

while ! curl -sSf "$GITLAB_EXTERNAL_URL" > /dev/null; do sleep 5; done;

REGISTRATION_TOKEN=$(docker exec gitlab gitlab-rails runner --environment=production "puts Gitlab::CurrentSettings.current_application_settings.runners_registration_token")

docker exec gitlab-runner \
  gitlab-runner register \
    --non-interactive \
    --name "gitlab-local" \
    --url "$GITLAB_EXTERNAL_URL" \
    --registration-token "$REGISTRATION_TOKEN" \
    --executor docker \
    --docker-volumes /var/run/docker.sock:/var/run/docker.sock \
    --tag-list "gitlab,local" \
    --docker-image "docker:stable-dind" \
    --run-untagged=true \
    --locked=false
