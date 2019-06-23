#!/usr/bin/env bash

set -xe

export MAVEN_OPTS='-Xms1568m -Xmx1568m'

while getopts ":dv:" opt; do
  case $opt in
    d) MAVEN_DEPLOY="1"
    ;;
    v) RELEASE_NUMBER="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

while getopts ":a:e:d:h:" opt; do
  case $opt in
    a) APP_ID="$OPTARG"
    ;;
    e) DEPLOY_ENVIRONMENT="$OPTARG"
    ;;
    d) BATCH_JDBC_SERVER="$OPTARG"
    ;;
    h) EXPOSED_API="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

if [[ -n "$RELEASE_NUMBER" ]]
then
    mvn -B -DnewVersion=${RELEASE_NUMBER} -DgenerateBackupPoms=false versions:set
fi

if [[ -n "$MAVEN_DEPLOY" ]]
then
    mvn -B $BUILD_PROPERTIES -U clean deploy
else
    mvn -B $BUILD_PROPERTIES -U clean install
fi
