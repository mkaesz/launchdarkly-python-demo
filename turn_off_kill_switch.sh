#!/bin/sh
curl -i -X PATCH \
  'https://app.launchdarkly.com/api/v2/flags/demo-project/new-feature-kill-switch' \
  -H "Authorization: $LAUNCHDARKLY_ACCESS_TOKEN" \
  -H 'Content-Type: application/json; domain-model=launchdarkly.semanticpatch' \
  -d '{
          "environmentKey": "staging",
          "instructions": [ { "kind": "turnFlagOff" } ]
      }'

