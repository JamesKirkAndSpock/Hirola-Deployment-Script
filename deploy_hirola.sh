#!/usr/bin/env bash

set -o errexit
set -o pipefail
# set -o nounset
# set -o xtrace

get_var() {
  local name="$1"

  curl -s -H "Metadata-Flavor: Google" \
    "http://metadata.google.internal/computeMetadata/v1/instance/attributes/${name}"
}

get_required_variables () {
    BRANCH="$(get_var "circleBranch")" 
    ENVIRONMENT="$(get_var "environment")"
    ENV_INSTANCE="$(get_var "env")"
    export IP_ADDRESS="$(get_var "ipAddress")"
    export HOST="$(get_var "host")"
    export DATABASE_NAME="$(get_var "databaseName")"
    export USER="$(get_var "user")"
    export PASSWORD="$(get_var "password")"
    export DJANGO_SETTINGS_MODULE=hirola.settings.${ENVIRONMENT}
    export POSTGRES_IP="$(get_var "postgresIp")"
    export SECRET_KEY="$(sudo openssl rand -hex 64)"
    export GS_BUCKET_NAME="$(get_var "gsBucketName")"
    export GS_BUCKET_URL="$(get_var "gsBucketURL")"
    export CACHE_IP="$(get_var "cacheIP")"
    export CACHE_PORT="$(get_var "cachePort")"
    export TWILIO_ACCOUNT_SID="$(get_var "twilioSID")"
    export TWILIO_AUTH_TOKEN="$(get_var "twilioTOK")"
    export EMAIL_HOST="$(get_var "emailHost")"
    export EMAIL_PORT="$(get_var "emailPort")"
    export EMAIL_HOST_USER="$(get_var "emailHostUser")"
    export EMAIL_HOST_PASSWORD="$(get_var "emailHostPass")"
    export DEFAULT_FROM_EMAIL="$(get_var "defaultEmail")"
    export SESSION_COOKIE_AGE="$(get_var "sessionAge")"
    export SESSION_COOKIE_AGE_KNOWN_DEVICE="$(get_var "sessionAgeKD")"
    export SECRET_GS_BUCKET_NAME="$(get_var "secretGsBucketName")"
    export CHANGE_EMAIL_EXPIRY_MINUTES_TIME="$(get_var "changeEmailTime")"
    export INACTIVE_EMAIL_EXPIRY_MINUTES_TIME="$(get_var "inactiveEmailTime")"
}

copy_lets_encrypt_credentials () {
    sudo mkdir -p /etc/letsencrypt/renewal-hooks/deploy 
    sudo gsutil -m rsync -d -r gs://"${SECRET_GS_BUCKET_NAME}"/letsencrypt/letsencrypt-"${ENV_INSTANCE}" /etc/letsencrypt
    sudo gsutil cp gs://"${SECRET_GS_BUCKET_NAME}"/nginx-configurations/"${ENV_INSTANCE}"/nginx.conf /etc/nginx/conf.d/
    cd /etc/letsencrypt
    sudo mkdir renewal-hooks/post renewal-hooks/pre
    sudo chmod 700 accounts archive keys live accounts/acme-v02.api.letsencrypt.org 
    sudo chmod 644 cli.ini options-ssl-nginx.conf ssl-dhparams.pem .updated-options-ssl-nginx-conf-digest.txt .updated-ssl-dhparams-pem-digest.txt csr/0000_csr-certbot.pem renewal/"${HOST}".conf
    sudo chmod 755 csr renewal archive/"${HOST}" live/"${HOST}"
    sudo chmod 600 keys/0000_key-certbot.pem
    sudo chmod -R 755 renewal-hooks
    sudo ln -s /etc/letsencrypt/archive/"${HOST}"/cert1.pem live/"${HOST}"/cert.pem
    sudo ln -s /etc/letsencrypt/archive/"${HOST}"/chain1.pem live/"${HOST}"/chain.pem
    sudo ln -s /etc/letsencrypt/archive/"${HOST}"/fullchain1.pem live/"${HOST}"/fullchain.pem
    sudo ln -s /etc/letsencrypt/archive/"${HOST}"/privkey1.pem live/"${HOST}"/privkey.pem
}

copy_cronjobs () {
    sudo gsutil cp gs://"${SECRET_GS_BUCKET_NAME}"/cronjobs/daily/hirola.sh /etc/cron.daily/hirola
    sudo chmod 0511 /etc/cron.daily/hirola
}

copy_supervisord_conf () {
    sudo gsutil cp gs://"${SECRET_GS_BUCKET_NAME}"/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
    sudo gsutil cp gs://"${SECRET_GS_BUCKET_NAME}"/start-script/start.sh /usr/local/bin/start-app
    sudo chmod +x /usr/local/bin/start-app
}

remove_precambrian_pip() {
    sudo apt-get remove python3-pip -y
    wget https://bootstrap.pypa.io/get-pip.py
    sudo python3 get-pip.py
}

install_and_start_repo () {
    cd ~
    git clone -b ${BRANCH} https://github.com/JamesKirkAndSpock/Hirola
    pip3 install -r ~/Hirola/hirola/requirements.txt
    python3 ~/Hirola/hirola/manage.py makemigrations front
    python3 ~/Hirola/hirola/manage.py migrate front
    python3 ~/Hirola/hirola/manage.py migrate
    python3 ~/Hirola/hirola/manage.py collectstatic --no-input
    sudo systemctl start memcached
    sudo nginx -s reload
    sudo systemctl restart supervisor
}


main () {
    get_required_variables
    copy_lets_encrypt_credentials
    copy_cronjobs
    copy_supervisord_conf
    remove_precambrian_pip
    install_and_start_repo
}

main "$@"
