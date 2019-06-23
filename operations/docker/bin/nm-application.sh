#!/usr/bin/env bash

if [[ "$DEBUG_ENV" ]]; then
    echo DUMPING ENVIRONMENT VARS
    printenv
fi

exec java $JAVA_OPTS -jar /nm-application.jar
