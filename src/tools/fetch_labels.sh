#!/bin/bash
# Fetches/obtains the labels that will be applied to the given PR.
#
# Arguments:
# [0]: Taken by Bash, the name of the script
# [1]: The repositories filename to obtain the configuration from. E.g.: `repos.lua`
# [2]: The mode that will be used. Available modes are: "fetch" and "update"
# [3]: The repository name. E.g.: "panqkart/panqkart"

labels=""

# Taken and slightly edited from https://github.com/dependabot/dependabot-core/blob/main/common/lib/dependabot/pull_request_creator/labeler.rb#L9
dependencies_label_regex='^[^/]*[Dd][Ee][Pp]endenc[^/]+$'

if [ "$2" == "fetch" ]; then
    # Find a way to use a Bash argument in a Lua script
    labels=$(lua -e "local labels = require("$1").config; if labels.labels_fetch then print(labels.labels_fetch) end") || echo "repo-fetch,dependencies"
elif [ "$2" == "update" ]; then
    labels=$(lua -e "local labels = require("$1").config; if labels.labels_update then print(labels.labels_update) end") || echo "dependencies"
else
    # Invalid mode. Use the regex to search for the closest match.
    repo_labels=$(gh api repos/$3/labels | jq -r '.[].name')

    for label in $repo_labels; do
        if [[ $label =~ $dependenies_label_regex ]]; then
            labels=$label
            break
        else
            # No match found. Create a `dependencies` label by running the `create_label` command in GH CLI.
            gh api repos/$3/labels -f name=dependencies -f color=0366d6 -f description="Pull requests that update a dependency file"
            labels="dependencies"
        fi
    done
fi

echo $labels
