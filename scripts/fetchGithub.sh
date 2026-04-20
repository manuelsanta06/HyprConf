#!/bin/bash

TOKEN="$(cat ~/resources/env.json|jq -r '.GITHUB_TOKEN')"
USERNAME="manuelsanta06"

QUERY="query { user(login: \"$USERNAME\") { contributionsCollection { contributionCalendar { weeks { contributionDays { contributionCount } } } } } }"

JSON_PAYLOAD=$(jq -n --arg q "$QUERY" '{query: $q}')

curl -s \
  -H "Authorization: bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -X POST \
  -d "$JSON_PAYLOAD" \
  https://api.github.com/graphql |jq -c
