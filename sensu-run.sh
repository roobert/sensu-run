#!/usr/bin/env bash

# NOTE: this is a very basic proof of concept..

function check_run () {
  FILE=$1
   
  if [[ -r "$FILE"  ]]; then
    COMMAND=$(cat $FILE | jq -r '.checks[].command')

    if echo $COMMAND | grep sudo > /dev/null 2>&1; then
      echo "# stripping sudo from command"
      COMMAND=$(echo $COMMAND | cut -d' ' -f 2-)
    fi

    echo "# running command: $COMMAND"

    if [[ $(echo $COMMAND | awk '{ print $1 }') =~ \.rb$ ]]; then
      /opt/sensu/embedded/bin/ruby $COMMAND
    else
      $COMMAND
    fi
    echo
  else
    echo "no such file: $FILE.json"
  fi
}

function usage () {
  echo "$0 -h|-help"
  echo "$0 -a|-all      # run all checks"
  echo "$0 <check name> # run check"
  exit 1
}

if [[ "$1" =~ --help|-h ]] || [[ ! "$1" =~ --all|-a ]]; then
  usage
fi

if [[ ! -r /etc/sensu/conf.d/checks ]]; then
  echo 'could not read from sensu check directory'
  exit 1
fi

if [[ $1 =~ -a|--all ]]; then
  for check_file in $(find /etc/sensu/conf.d/checks -name '*.json'); do
    check_run $check_file
  done
else
  for check in $*; do
    check_file=$(find /etc/sensu/conf.d/checks -name "$check.json")
    check_run $check_file
  done
fi

