#!/bin/bash
set -e

if [ -z "$AZP_URL" ]; then
  echo 1>&2 "error: missing AZP_URL environment variable"
  exit 1
fi

if [ -z "$POLARIS_URL" ]; then
  echo 1>&2 "error: missing POLARIS_URL environment variable"
  exit 1
fi

if [ -z "$POLARIS_ACCESS_TOKEN" ]; then
  echo 1>&2 "error: missing POLARIS_ACCESS_TOKEN environment variable"
  exit 1
fi

if [ -z "$AZP_TOKEN_FILE" ]; then
  if [ -z "$AZP_TOKEN" ]; then
    echo 1>&2 "error: missing AZP_TOKEN environment variable"
    exit 1
  fi

  AZP_TOKEN_FILE=/azp/.token
  echo -n $AZP_TOKEN > "$AZP_TOKEN_FILE"
fi

unset AZP_TOKEN

if [ -n "$AZP_WORK" ]; then
  mkdir -p "$AZP_WORK"
fi

export AGENT_ALLOW_RUNASROOT="1"

cleanup() {
  if [ -e config.sh ]; then
    print_header "Cleanup. Removing Azure Pipelines agent..."

    # If the agent has some running jobs, the configuration removal process will fail.
    # So, give it some time to finish the job.
    while true; do
      ./config.sh remove --unattended --auth PAT --token $(cat "$AZP_TOKEN_FILE") && break

      echo "Retrying in 30 seconds..."
      sleep 30
    done
  fi
}

print_header() {
  lightcyan='\033[1;36m'
  nocolor='\033[0m'
  echo -e "${lightcyan}$1${nocolor}"
}

# Let the agent ignore the token env variables
export VSO_AGENT_IGNORE=AZP_TOKEN,AZP_TOKEN_FILE

source ./env.sh

print_header "1. Configuring Azure Pipelines agent..."

./config.sh --unattended \
  --agent "${AZP_AGENT_NAME:-$(hostname)}" \
  --url "$AZP_URL" \
  --auth PAT \
  --token $(cat "$AZP_TOKEN_FILE") \
  --pool "${AZP_POOL:-Default}" \
  --work "${AZP_WORK:-_work}" \
  --replace \
  --acceptTeeEula & wait $!

print_header "2. Initializing Polaris client software..."

POLARIS_DOWNLOAD=$POLARIS_URL/api/tools/polaris_cli-linux64.zip
echo POLARIS_URL=$POLARIS_URL
echo POLARIS_ACCESS_TOKEN=$POLARIS_ACCESS_TOKEN
curl -LsS -o polaris.zip $POLARIS_DOWNLOAD
unzip -j -d polaris-cli polaris.zip

mkdir temp-src && cd temp-src && ../polaris-cli/polaris --persist-config --co capture.build.buildCommands="null" --co capture.build.cleanCommands="null" --co capture.fileSystem="null" --co serverUrl=$POLARIS_URL configure && cd ..
export POLARIS_FF_ENABLE_COVERITY_INCREMENTAL=true
cd temp-src && echo Foo.java > changeset.txt && ../polaris-cli/polaris analyze -w --coverity-ignore-capture-failure --incremental ./changeset.txt  || cd .. || true

print_header "3. Running Azure Pipelines agent..."

trap 'cleanup; exit 0' EXIT
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

# To be aware of TERM and INT signals call run.sh
# Running it with the --once flag at the end will shut down the agent after the build is executed
./run.sh "$@" &

wait $!
