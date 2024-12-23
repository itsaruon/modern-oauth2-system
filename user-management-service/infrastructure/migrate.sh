#!/usr/bin/env sh
SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id $SECRET_KEY --query 'SecretString' --output text)
ENV_VARS=$(echo $SECRET_JSON | jq -r 'to_entries[] | "\(.key)=\(.value)"')

# Set the environment variables
eval $ENV_VARS
export POSTGRES_DB_PASSWORD=$POSTGRES_DB_PASSWORD

if [ $? -eq 0 ]; then
    migrate -path /database -database "postgres://${POSTGRES_DB_USER}:${POSTGRES_DB_PASSWORD}@${POSTGRES_DB_HOST}:${POSTGRES_DB_PORT}/${POSTGRES_DB_NAME}?sslmode=disable" -verbose up
else
    echo "Unable to substitute credentials"
    exit 1
fi
