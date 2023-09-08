local config = {
    labels_fetch = "repos-fetch,dependencies",       -- Labels that will be added to the PRs when the `fetch-repos.lua` script is run, separated by commas in the same string(!).
    labels_update = "dependencies",                  -- Labels that will be added to the PRs when running the `update-repos.lua` script, separated by commas in the same string(!).
    pr_body = {                                      -- The body of the PRs that will be used. `both` is used when both actions are run in the same PR.
        update = "This PR updated all the subtrees." ..
            "The updated subtrees are:" ..
            "- Test 1." ..
            "- Test 2.",
        fetch = "This PR fetched all the subtrees.",
        both = "This PR both updates subtrees and fetches new ones."
    }
}

local repos = {
    {
        name = "",            -- Name of the repository, used as directory name as well.
        url = "",             -- URL link. Any VCS link (GitLab, GitHub, NotABug, etc.) should be used.
        dir = "libs/",        -- Directory where the repository will be cloned.
        def_branch = "main"   -- The default branch of the repository. If not specified, the script will try to
                              -- find the default branch name. Currently supports GitHub, GitLab, and BitBucket.
    }
    -- Add any other repositories here.
}

return {
    repos = repos,
    config = config
}
