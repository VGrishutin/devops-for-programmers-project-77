export $(grep -v '^#' .env | xargs)
TF_CLI_ARGS_init="-backend-config=access_key='$TF_VAR_access_key' -backend-config='secret_key=$TF_VAR_secret_key'"
export TF_CLI_ARGS_init
