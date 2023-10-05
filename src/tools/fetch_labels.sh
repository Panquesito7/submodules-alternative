#!/bin/bash
# Fetches/obtains the labels that will be applied to the given PR.
#
# Arguments:
# [0]: Taken by Bash, the name of the script
# [1]: The repositories filename to obtain the configuration from. E.g.: `repos.lua`
# [2]: The mode that will be used. Available modes are: "fetch" and "update"

labels=""

if [ "$2" == "fetch" ]; then
    labels=$(lua -e 'local labels = require("$1").config; if labels.labels_fetch then print(labels.labels_fetch) end') || "repo-fetch,dependencies"
elif [ "$2" == "update" ]; then
    labels=$(lua -e 'local labels = require("$1").config; if labels.labels_update then print(labels.labels_update) end') || "dependencies"
else
    # Invalid mode. Basic labels will be used instead.
    labels="dependencies"
fi

echo $labels
