local repos = {
    {
        name = "",              -- Name of the module, used as directory name as well.
        url = "",               -- URL link. Any VCS link (GitLab, GitHub, NotABug, etc.) should be used.
        dir = "libs/"           -- Directory where the repository will be cloned. Always include `/` at the end.
    }
    -- Add any other repositories here.
}

return {
    repos = repos
}
