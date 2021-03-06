#!/usr/bin/env bash
set -u 

# Copy files from /usr/share/runner/ref into ${RUNNER_CONFIG}
# So the initial /app is set with expected content.
# Don't override, as this is just a reference setup

copy_reference_files() {
  local log="$RUNNER_CONFIG/copy_reference_file.log"
  local ref="/usr/share/runner/ref"

  if mkdir -p "${RUNNER_CONFIG}/runner" && touch "${log}" > /dev/null 2>&1 ; then
      cd "${ref}"
      local reflink=""
      if cp --help 2>&1 | grep -q reflink ; then
          reflink="--reflink=auto"
      fi
      if [ -n "$(find "${HOME}/work/_update" -maxdepth 0 -type d -not -empty 2>/dev/null)" ]; then
          cd $HOME/work/_update
          echo "--- Copying all files to ${RUNNER_CONFIG}/runner at $(date)" >> "${log}.update"
          cp -rv ${reflink} . "${RUNNER_CONFIG}/runner" >> "${log}"
          rm -rf $HOME/work/_update*
      elif [ -n "$(find "${RUNNER_CONFIG}/runner" -maxdepth 0 -type d -empty 2>/dev/null)" ] ; then
          # destination is empty...
          echo "--- Copying all files to ${RUNNER_CONFIG}/runner at $(date)" >> "${log}"
          cp -rv ${reflink} . "${RUNNER_CONFIG}/runner" >> "${log}"
      fi
      echo >> "${log}"
  else
    echo "Can not write to ${log}. Wrong volume permissions? Carrying on ..."
  fi
}

# create registration token
registrationToken() {
  local fullname="${GITHUB_REPOSITORY#*github.com/}"
  local owner="${fullname%%/*}"
  local repo="${fullname##*/}"
  local token="$(curl -sS --request POST \
    --url "https://api.github.com/repos/${owner}/${repo}/actions/runners/registration-token?=" \
    --header 'accept: application/vnd.github.v3+json' \
    --header "authorization: Bearer ${GITHUB_TOKEN}" \
    --header 'content-type: application/json' | jq -r '.token')"
  echo $token
}

# configure the runner
configureRunner() {
  # make sure we only run this once!
  if [ ! -e /app/configured ]; then
    local token=$(registrationToken)
    # Configure the runner
    /app/runner/config.sh \
      --url "${GITHUB_REPOSITORY}" \
      --token "${token}" \
      --startuptype service \
      --unattended \
      --work "${HOME}/work"
    touch /app/configured
  fi
}

owd="$(pwd)"
copy_reference_files
unset RUNNER_CONFIG

cd "${owd}"
unset owd

mkdir -p $HOME/work

# If no arguments passed, start the runner.
if [[ $# -lt 1 ]]; then
  configureRunner
  printf "Executing GitHub Runner for $GITHUB_REPOSITORY\n"
  exec /app/runner/run.sh
fi

# Run the user process, example `bash`
exec $@
#exec tail -f /dev/null 
