#!/bin/sh

get_var() {
  local name="$1"
  curl -s -H "Metadata-Flavor: Google" \
    "http://metadata.google.internal/computeMetadata/v1/instance/attributes/${name}"
}
get_required_variables () {
    ENVIRONMENT="$(get_var "environment")"
    IP_ADDRESS="$(get_var "ipAddress")"
    export IP_ADDRESS
    HOST="$(get_var "host")"
    export HOST
    DATABASE_NAME="$(get_var "databaseName")"
    export DATABASE_NAME
    USER="$(get_var "user")"
    export USER
    PASSWORD="$(get_var "password")"
    export PASSWORD
    DJANGO_SETTINGS_MODULE=hirola.settings.${ENVIRONMENT}
    export DJANGO_SETTINGS_MODULE
    POSTGRES_IP="$(get_var "postgresIp")"
    export POSTGRES_IP
    SECRET_KEY="$(sudo openssl rand -hex 64)"
    export SECRET_KEY
    GS_BUCKET_NAME="$(get_var "gsBucketName")"
    export GS_BUCKET_NAME
    GS_BUCKET_URL="$(get_var "gsBucketURL")"
    export GS_BUCKET_URL
    CACHE_IP="$(get_var "cacheIP")"
    export CACHE_IP
    CACHE_PORT="$(get_var "cachePort")"
    export CACHE_PORT
    TWILIO_ACCOUNT_SID="$(get_var "twilioSID")"
    export TWILIO_ACCOUNT_SID
    TWILIO_AUTH_TOKEN="$(get_var "twilioTOK")"
    export TWILIO_AUTH_TOKEN
    EMAIL_HOST="$(get_var "emailHost")"
    export EMAIL_HOST
    EMAIL_PORT="$(get_var "emailPort")"
    export EMAIL_PORT
    EMAIL_HOST_USER="$(get_var "emailHostUser")"
    export EMAIL_HOST_USER
    EMAIL_HOST_PASSWORD="$(get_var "emailHostPass")"
    export EMAIL_HOST_PASSWORD
    DEFAULT_FROM_EMAIL="$(get_var "defaultEmail")"
    export DEFAULT_FROM_EMAIL
    SESSION_COOKIE_AGE="$(get_var "sessionAge")"
    export SESSION_COOKIE_AGE
    SESSION_COOKIE_AGE_KNOWN_DEVICE="$(get_var "sessionAgeKD")"
    export SESSION_COOKIE_AGE_KNOWN_DEVICE
    SECRET_GS_BUCKET_NAME="$(get_var "secretGsBucketName")"
    export SECRET_GS_BUCKET_NAME
    CHANGE_EMAIL_EXPIRY_MINUTES_TIME="$(get_var "changeEmailTime")"
    export CHANGE_EMAIL_EXPIRY_MINUTES_TIME
    INACTIVE_EMAIL_EXPIRY_MINUTES_TIME="$(get_var "inactiveEmailTime")"
    export INACTIVE_EMAIL_EXPIRY_MINUTES_TIME
}
run_command() {
    get_required_variables
    cd ~/Hirola/hirola || exit
    python3 manage.py changeemail
    python3 manage.py inactiveuser
}
main () {
    run_command
}
main
