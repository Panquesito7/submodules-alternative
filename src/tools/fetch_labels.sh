#!/bin/bash
# Fetches/obtains the labels that will be applied to the given PR.
#
# Arguments:
# [0]: Taken by Bash, the name of the script
# [1]: The action path to obtain the necessary files.
# [2]: The repositories filename to obtain the configuration from. E.g.: `repos.lua`
# [3]: The mode that will be used. Available modes are: "fetch" and "update"

labels=""

if [ args[3] == "fetch" ]; then
    labels=$(lua -e 'local labels = require("args[2]").config; if labels.labels_fetch then print(labels.labels_fetch) end') || "repo-fetch,dependencies"
elif [ args[3] == "update" ]; then
    labels=$(lua -e 'local labels = require("args[2]").config; if labels.labels_update then print(labels.labels_update) end') || "dependencies"
else
    echo "Invalid mode. Providing basic labels"
    labels="dependencies"
fi

echo $labels
