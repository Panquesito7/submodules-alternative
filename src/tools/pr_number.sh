#!/bin/bash
# Obtains the given PR number.
#
# Arguments:
# [0]: Taken by Bash, the name of the script
# [1]: The current branch name. Usually `${GITHUB_REF##*/}`
# [2]: The branch name that has the new changes

pr=$(gh pr list --base args[1] --head args[2])
pr_number=$(echo $pr | cut -d' ' -f1)

# Does it have any content?
if [ -z "$pr_number" ];
then
    echo "No PR (number?) was found."
    exit 1
else
    echo $pr_number
fi
