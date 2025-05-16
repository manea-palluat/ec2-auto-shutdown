#!/bin/bash

set -e #the script will exit if any command fails

prompt() {
  [ -z "${!1}" ] && read -p "$2: " val && export $1="$val"
}

#this function:
# - checks if the variable is set with [ -z "${!1}" ],
#the -z flag checks if the variable is empty (it's a feature of bash)
#and the "${!1}" syntax is used to get the value of the variable whose name is stored in $1
# - if the variable is not set, it prompts the user for a value with read -p "$2: " val
# - and then exports the variable with export $1="$val"
# - the function is called with the variable name and the prompt message as arguments

#always load .env if present cause it contains the AWS credentials
[ -f /app/.env ] && export $(grep -v '^#' /app/.env | xargs)

#we prompt the user for the AWS credentials if not set
prompt AWS_ACCESS_KEY_ID     "AWS Access Key ID"
prompt AWS_SECRET_ACCESS_KEY "AWS Secret Access Key"
prompt AWS_REGION            "AWS Region (e.g. eu-west-1)"

#apply only: prompt for the rest (alert email, instance ids, stop time) and create the terraform.tfvars.json file
if [ "$1" = "apply" ]; then
  prompt ALERT_EMAIL   "Alert email"
  prompt INSTANCE_IDS  "EC2 instance IDs (comma-separated)"
  prompt STOP_TIME     "Stop time in Paris (hh:mm, 24h)"

  if [[ ! "$STOP_TIME" =~ ^([01]?[0-9]|2[0-3]):[0-5][0-9]$ ]]; then
    echo "❌ STOP_TIME must be hh:mm" >&2
    exit 1
  fi

  IFS=":" read h m <<<"$STOP_TIME"
  uh=$((10#$h - 2)); (( uh<0 )) && uh=$((uh+24))
  CRON="cron(${m} ${uh} * * ? *)"

  mkdir -p /app/state
  cat > /app/state/terraform.tfvars.json <<EOF
{
  "alert_email": "${ALERT_EMAIL}",
  "instance_ids": ["$(echo ${INSTANCE_IDS} | sed 's/,/\",\"/g')"],
  "stop_cron_expr": "${CRON}"
}
EOF
fi

#init
cd /app
terraform init -input=false

#apply or destroy
case "$1" in
  apply)
    terraform apply \
      -var-file="state/terraform.tfvars.json" \
      -state="state/terraform.tfstate" \
      -auto-approve
    echo
    echo "- Scheduled stop at ${STOP_TIME} Paris (UTC ${uh}:${m})"
    echo "- Alerts : ${ALERT_EMAIL}"
    echo "- Instances : ${INSTANCE_IDS}"
    ;;
  destroy)
    terraform destroy \
      -var-file="state/terraform.tfvars.json" \
      -state="state/terraform.tfstate" \
      -auto-approve
    echo
    echo "Destroy complete."
    ;;
  *)
    echo "Usage: \$0 apply|destroy" >&2
    exit 1
    ;;
esac
