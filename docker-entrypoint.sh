set -e

cd /app/state 

  export $(grep -v '^#' .env | xargs)
fi

: "${AWS_ACCESS_KEY_ID:?Missing AWS Access Key ID}"
: "${AWS_SECRET_ACCESS_KEY:?Missing AWS Secret Access Key}"
: "${AWS_REGION:?Missing AWS Region}"
: "${ALERT_EMAIL:?Missing Alert Email}"
: "${INSTANCE_IDS:?Missing Instance IDs}"
: "${STOP_HOUR:?Missing Stop Hour (UTC)}"

export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION

echo 'Generating terraform.tfvars.json'
cat > terraform.tfvars.json <<EOF
{
  "alert_email": "${ALERT_EMAIL}",
  "instance_ids": ["$(echo ${INSTANCE_IDS} | sed 's/,/","/g')"],
  "stop_hour": ${STOP_HOUR}
}
EOF

terraform init
t
make apply -var-file="terraform.tfvars.json" -auto-approve