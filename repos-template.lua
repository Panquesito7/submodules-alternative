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
    repos = repos
}
