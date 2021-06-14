#!/bin/bash
#set -ex
#: ${PLANEMO_OPTIONS:=""}  # e.g. PLANEMO_OPTIONS="--verbose"

GALAXY_URL="https://usegalaxy.be"
GALAXY_BE_KEY=$1
date_suffix=$(date '+%Y_%m_%d')
echo \
"__default: belgium
belgium:
  key: $GALAXY_BE_KEY
  url: $GALAXY_URL" > parsec_conf.yml


echo \
"---
title: Workflow tests
layout: post
categories: [Tests]
description: \"Workflow tests from $date_suffix\"
---

| Workflow name | Testing results |
| :------------- |: ---------------:|" > test_results.md

echo $SHELL
pwd
find ./workflows/ -name "*.ga" -exec $SHELL -c '
    function test_workflow () {
        #echo "calling function test_workflow"
        #echo "$1"
        #echo "Fake result for workflow $0 = passed"
        #echo "-----"
        #wf_path="./workflows/mini_test/mini_test.ga"
        #cat parsec_conf.yml
        wf_path=$1
        echo $wf_path
        GALAXY_URL=$2
        GALAXY_BE_KEY=$3
        #echo "url is $GALAXY_URL"
        wf_name=`cat $wf_path | jq -r .name`
        date_suffix=$4
        history_name=$wf_name\_$date_suffix
        # Run test.
        #echo $history_name
        #parsec --path parsec_conf.yml histories get_histories --name "$history_name"
        #exit
        #history_id=$(parsec --path parsec_conf.yml histories get_histories --name "$history_name" | jq -r .[0].id)
        set +e # Do not die if planemo returns non-zero
        planemo test \
            --history_name "$history_name" \
            --galaxy_url "$GALAXY_URL" \
            --galaxy_user_key "$GALAXY_BE_KEY" \
            --no_shed_install \
            --engine external_galaxy \
            "$wf_path";
        planemo_exit_code=$?
        #echo "finished test"
        set -e
        if (( planemo_exit_code > 0 )); then
            history_id=$(parsec --path parsec_conf.yml histories get_histories --name "$history_name" | jq -r .[0].id)
            history_slug=$(parsec --path parsec_conf.yml histories update_history --importable $history_id | jq -r .username_and_slug)

            #echo "<html><head></head><body style=\"margin:0;padding:0;\"><iframe style=\"border:none;width:100%;height:100%;\" src=\"https://usegalaxy.eu/$history_slug\"></iframe></body></html>"> history.html
        else
            # Otherwise immediately delete
            history_id=$(parsec --path parsec_conf.yml histories get_histories --name "$history_name" | jq -r .[0].id)
            parsec --path parsec_conf.yml histories delete_history --purge $history_id
            echo "| $wf_name | ![](https://img.shields.io/static/v1?label=workflow&message=passing&color=green) |" >> test_results.md
            #echo "<html><head></head><body>Test was completely successful</body></html>"> history.html
        fi
        #exit $planemo_exit_code
    }
    test_workflow "$@"' $SHELL {} $GALAXY_URL $GALAXY_BE_KEY $date_suffix \;
#find ./workflows/mini_test/ -name "*.ga" -exec $SHELL -c '
#' {} \;




exit


# make history public
# publish_history just makes the history public
#   1. get history_id
#   2. Update  update_history(published=True)   How do I get the link???
#python publish_history.py --name $history_name --key 
