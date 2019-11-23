#!/usr/bin/env bash

while getopts a: OPTION
  do
    case "${OPTION}"
      in
      a) AWS_ACCT=${OPTARG};;
      *) echo "usage: $0 [-a]" >&2
        exit 1 ;;
    esac
done


export AWS_REGION=ap-southeast-2
GLOBAL_ROLE='core-pipeline'

echo 'Master Account ID:' "$AWS_ACCT" # Get AWS Details out of the associative array

TEMP_STS=$(aws sts assume-role \
  --role-arn "arn:aws:iam::$AWS_ACCT:role/$GLOBAL_ROLE" \
  --role-session-name awscli_TEMP_STS)

export AWS_ACCESS_KEY_ID=$(echo "$TEMP_STS" | jq -r .Credentials.AccessKeyId)
export AWS_SECRET_ACCESS_KEY=$(echo "$TEMP_STS" | jq -r .Credentials.SecretAccessKey)
export AWS_SESSION_TOKEN=$(echo "$TEMP_STS" | jq -r .Credentials.SessionToken)
