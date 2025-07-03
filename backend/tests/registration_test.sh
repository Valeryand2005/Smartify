#!/bin/bash
set -e

#Hi

echo "Running registration test..."

RESPONSE=$(curl -s -X POST http://localhost:22025/api/registration_emailvalidation \
     -H "Content-Type: application/json" \
     -d '{"email":"test@mail.com"}')

BODY=$(echo "$RESPONSE" | head -n -1)
STATUS=$(echo "$RESPONSE" | tail -n1)

CODE_VALUE=$(echo "$STATUS" | jq -r '.code')

if [ "$CODE_VALUE" -ne 200 ]; then
  echo "❌ Registration emailvalidation failed: HTTP $STATUS"
  echo "$BODY"
  exit 1
fi

echo "✅ Email validation request succeeded"

CODE=$(curl -s http://localhost:8025/api/v2/messages \
     | jq -r '.items[0].Content.Body' \
     | grep -o '[0-9]\{6\}')
echo "MAIL_CODE=$CODE" >> $GITHUB_ENV

if [ -z "$CODE" ]; then
  echo "❌ No code found in Mailhog email."
  echo "$CODE"
  exit 1
fi


RESPONSE=$(curl -s -X POST http://localhost:22025/api/registration_codevalidation \
     -H "Content-Type: application/json" \
     -d '{"email":"test@mail.com","code":"'"$MAIL_CODE"'"}')

BODY=$(echo "$RESPONSE" | head -n -1)
CODE_VALUE=$(echo "$STATUS" | jq -r '.code')

if [ "$CODE_VALUE" -ne 200 ]; then
  echo "❌ Registration codevalidation failed: HTTP $STATUS"
  echo "$BODY"
  exit 1
fi

echo "✅ Email codevalidation request succeeded"

RESPONSE=$(curl -s -X POST http://localhost:22025/api/registration_password \
     -H "Content-Type: application/json" \
     -d '{"email":"test@mail.com","password":"Loh1725!"}')

BODY=$(echo "$RESPONSE" | head -n -1)
CODE_VALUE=$(echo "$STATUS" | jq -r '.code')

if [ "$CODE_VALUE" -ne 200 ]; then
  echo "❌ Registration registration_password failed: HTTP $STATUS"
  echo "$BODY"
  exit 1
fi

echo "✅ Email registration_password request succeeded"


