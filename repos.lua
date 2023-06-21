local repos = {
    {
        name = "",              -- Name of the module, used as directory name as well.
        url = "",               -- URL link. Any VCS link (GitLab, GitHub, NotABug, etc.) should be used.
        dir = "libs/",          -- Directory where the repository will be cloned. Always include `/` at the end.
        clone_modules = true    -- Whether to clone modules of the given repository or not by using `--recursive`.
    }
    -- Add any other repositories here.
}

return {
    repos = repos
}
