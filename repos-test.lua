-- USED FOR TESTING PURPOSES ONLY.

local config = {
    labels_update = "dependencies,enhancement",
    pr_body = {
        update =
            "This is a PR that updated the subtrees.\n" ..
            "Updated submodules are:" ..
            "- Test 1." ..
            "- Test2. ",
        fetch = "This is a PR that fetched all the subtrees specified in `repos.lua`",
        both = "This is a PR that both updated and fetched the subtrees."
    }
}

local repos = {
    {
        name = "Minetest-WorldEdit",
        url = "https://github.com/Uberi/Minetest-WorldEdit",
        dir = "libs/"
    },
    {
        name = "panqkart",
        url = "https://github.com/panqkart/panqkart",
        dir = "libs/"
    },
    {
        name = "cloud_items",
        url = "https://github.com/minetest-mods/cloud_items",
        dir = "libs/"
    },
    {
        name = "mobs_redo",
        url = "https://notabug.org/TenPlus1/mobs_redo",
        dir = "libs/",
        def_branch = "master"
    }
}

return {
    repos = repos,
    config = config
}
