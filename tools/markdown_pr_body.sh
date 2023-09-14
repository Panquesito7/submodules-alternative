# Arguments:
# [0]: Taken by Bash, the name of the script
# [1]: The mode that will be used to generate the PR body. Available modes are: "all", "updated", "added"
# [2]:
# Is it separated or not?
# If it's separated, each subtree PR will use `pr_body_update_separate.txt` and put their subtree name replacing
# `{updated_subtree}`. Available options are: `true` or `false`
#
# [3]: The subtree name that will be used to replace `{updated_subtree}` in `pr_body_update_separate.txt`.

if [ "$1" == "all" ] || [ "$1" == "" ];
then
    # Reads the files and stores the lines in arrays
    mapfile -t updated_subtrees < updated_subtrees.txt
    mapfile -t added_subtrees < added_subtrees.txt

    # Adds backticks around each subtree name
    updated_subtrees=("${updated_subtrees[@]/#/\\\`}")
    added_subtrees=("${added_subtrees[@]/#/\\\`}")

    # Convert them to Markdown lists
    updated_subtrees_md=$(printf -- '- %s\\n' "${updated_subtrees[@]}")
    added_subtrees_md=$(printf -- '- %s\\n' "${added_subtrees[@]}")

    # Creates a temporary file for the PR body
    cat pr_body.txt > TEMP.txt

    if test -s updated_subtrees.txt;
    then
        sed -i -e "s|{updated_subtrees}|$updated_subtrees_md|g" TEMP.txt
    else
        sed -i -e '/The following subtrees were updated:/,/^$/d' TEMP.txt
        sed -i -e '/{updated_subtrees}/d' TEMP.txt
    fi

    if test -s added_subtrees.txt;
    then
        sed -i -e "s|{added_subtrees}|$added_subtrees_md|g" TEMP.txt
    else
        sed -i -e '/New subtrees were added:/,/^$/d' TEMP.txt
        sed -i -e '/{added_subtrees}/d' TEMP.txt
    fi

    # Do both files have no content?
    if ! test -s updated_subtrees.txt && ! test -s added_subtrees.txt;
    then
        echo "Various subtrees were updated or added in this PR." > TEMP.txt
    fi

    # Prints the PR body
    cat TEMP.txt

    # Delete the temporary PR body file
    rm TEMP.txt

elif [ "$1" == "updated" ];
then

    # Reads the files and stores the lines in arrays
    mapfile -t updated_subtrees < updated_subtrees.txt

    # Adds backticks around each subtree name
    updated_subtrees=("${updated_subtrees[@]/#/\\\`}")

    # Convert them to Markdown lists
    updated_subtrees_md=$(printf -- '- %s\\n' "${updated_subtrees[@]}")

    # Creates a temporary file for the PR body
    cat pr_body_update.txt > TEMP.txt

    # Prints the PR body
    cat TEMP.txt

    # Delete the temporary PR body file
    rm TEMP.txt

elif [ "$1" == "added" ];
then

    # Reads the files and stores the lines in arrays
    mapfile -t added_subtrees < added_subtrees.txt

    # Adds backticks around each subtree name
    added_subtrees=("${added_subtrees[@]/#/\\\`}")

    # Convert them to Markdown lists
    added_subtrees_md=$(printf -- '- %s\\n' "${added_subtrees[@]}")

    # Creates a temporary file for the PR body
    cat pr_body_fetch.txt > TEMP.txt

    # Prints the PR body
    cat TEMP.txt

    # Delete the temporary PR body file
    rm TEMP.txt

    else
        echo "Invalid mode. Available modes are: \"all\", \"updated\", \"added\""
        exit 1
fi

if [ "$2" == "true" ];
then
        # Creates a temporary file for the PR body
        cat pr_body_update_separate.txt > TEMP.txt

        # Add backticks around the subtree name
        updated_subtree="\\\`$3\\\`"

        # Replace the updated subtree name
        sed -i -e "s|{updated_subtree}|$updated_subtree|g" TEMP.txt

        # Prints the PR body
        cat TEMP.txt

        # Delete the temporary PR body file
        rm TEMP.txt
fi
