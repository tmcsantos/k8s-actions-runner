#!/usr/bin/env bash
set -u

# create remove token
removeToken() {
  local fullname="${GITHUB_REPOSITORY#*github.com/}"
  local owner="${fullname%%/*}"
  local repo="${fullname##*/}"
  local token="$(curl -sS --request POST \
    --url "https://api.github.com/repos/${owner}/${repo}/actions/runners/remove-token?=" \
    --header 'accept: application/vnd.github.v3+json' \
    --header "authorization: Bearer ${GITHUB_TOKEN}" \
    --header 'content-type: application/json' | jq -r '.token')"
  echo $token
}

# Remove this runner
removeRunner() {
  if [ -e /app/configured ]; then
    local token=$(removeToken)
    # Configure the runner
    /app/runner/config.sh \
      remove \
      --token "${token}"
    rm /app/configured
  fi
}

removeRunner
