#!/usr/bin/env bash

declare -A AWS_DETAILS OKTA_DETAILS
export AWS_REGION=ap-southeast-2

AWS_DETAILS=(
  [AUDIT_ACCT]='123456789012'
  [AWS_MASTER]='123456789012'
)

OKTA_DETAILS=(
  [ORG]='SOMEORG'
  [APPID]='SOMEAPPID'
  [OTHERID]='SOMEOTHERID'
)

URL='https://${OKTA_DETAILS[ORG]}.okta.com/home/amazon_aws/${OKTA_DETAILS[APPID]}/${OKTA_DETAILS[OTHERID]}'

function samlAssume() {
  saml2aws configure \
  --idp-account='saml_default' \
  --profile='saml_default' \
  --idp-provider='OKTA' \
  --mfa='Auto' \
  --url="${URL}" \
  --username="${USERNAME}" \
  --role='arn:aws:iam::123456789012:role/admin' \
  --session-duration=14400 \
  --skip-prompt
}

echo 'Master Account ID:' "${AWS_DETAILS[AUDIT_ACCT]}" # Get AWS Details out of the associative array

samlAssume

TEMP_STS=$(aws sts assume-role \
  --role-arn "arn:aws:iam::12345678901201123:role/admin" \
  --role-session-name "awscli_TEMP_STS")

export AWS_ACCESS_KEY_ID=$(echo "$TEMP_STS" | jq -r .Credentials.AccessKeyId)
export AWS_SECRET_ACCESS_KEY=$(echo "$TEMP_STS" | jq -r .Credentials.SecretAccessKey)
export AWS_SESSION_TOKEN=$(echo "$TEMP_STS" | jq -r .Credentials.SessionToken)
