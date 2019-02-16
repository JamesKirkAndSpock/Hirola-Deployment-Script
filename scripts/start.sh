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
start_app () {
    cd /root/Hirola/hirola || exit
    gunicorn -b 0.0.0.0:8000 --error-logfile /var/log/hirola-error.log hirola.wsgi
}
main () {
    get_required_variables
    start_app
}
main "$@"
