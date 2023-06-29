--
-- Helper functions that are used across the repository.
-- Copyright (C) 2023 David Leal (halfpacho@gmail.com)
--
-- This library is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- This library is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
--

--- @brief Verifies that all of the necessary variables
--- all set for all repositories. If not, the script will fail.
--- @param repo table The table containing all of the repositories.
--- @param i number The index of the repository to check.
--- @return nil
local function check_variables(repo, i)
    if repo[i].name == nil then
        print("Error: `name` is not set for repository " .. i)
        os.exit(1)
    end

    if repo[i].url == nil then
        print("Error: `url` is not set for repository " .. i)
        os.exit(1)
    end

    if repo[i].dir == nil then
        print("Error: `dir` is not set for repository " .. i)
        os.exit(1)
    end

    if repo[i].def_branch == nil then
        print("Warning: default branch not specified for `" .. repo[i].name .. "`. Attempting to obtain the default branch using the API.")
    end
end

--- @brief Gets the default branch for the given
--- repository. If no branch found, it will use the
-- fallback/specified branch in the repositories file.
--- @param repos table The table containing all of the repositories.
--- @param i number The index of the repository to check.
local function get_def_branch(repos, i)
    -- Get the current VCS that is being used.
    local branch
    local vcs = repos[i].url:match("https://(%w+).%w+")
    local owner, repo = repos[i].url:match(vcs .. ".%w+/(.+)/(.+)")

    -- Remove `.git` from `repo` if available.
    repo = repo:gsub(".git", "")

    -- Attempt to obtain the default branch name from the given URL.
    -- Currently supports: GitLab, GitHub, and BitBucket.
    local handle

    if vcs == "github" then
        handle = io.popen("wget -q -O - \"\"https://api.github.com/repos/" .. owner .. "/" .. repo .. "\"\" | jq -r '.default_branch'")
         if handle then
            -- Print message and update branch only if default branch not set.
            if repos[i].def_branch == nil then
                branch = handle:read("*a")
                handle:close()

                print("Found branch for `" .. repo .. "` using GitHub API.")
            else
                branch = repos[i].def_branch
            end
        else
            print("Error: Could not obtain the default branch name from the given URL.")
            os.exit(1)
            return nil
        end
    elseif vcs == "gitlab" then
        handle = io.popen("wget -q -O - \"\"https://gitlab.com/api/v4/projects/" .. owner .. "%2F" .. repo .. "\"\" | jq -r '.default_branch'")
        if handle then
            -- Print message and update branch only if default branch not set.
            if repos[i].def_branch == nil then
                branch = handle:read("*a")
                handle:close()

                print("Found branch for `" .. repo .. "` using GitLab API.")
            else
                branch = repos[i].def_branch
            end
        else
            print("Error: Could not obtain the default branch name from the given URL.")
            os.exit(1)
            return nil
        end
    elseif vcs == "bitbucket" then
        handle = io.popen("wget -q -O - \"\"https://api.bitbucket.org/2.0/repositories/" .. owner .. "/" .. repo .. "\"\" | jq -r '.mainbranch.name'")
        if handle then
            -- Print message and update branch only if default branch not set.
            if repos[i].def_branch == nil then
                branch = handle:read("*a")
                handle:close()

                print("Found branch for `" .. repo .. "` using BitBucket API.")
            else
                branch = repos[i].def_branch
            end
        else
            print("Error: Could not obtain the default branch name from the given URL.")
            os.exit(1)
            return nil
        end
    -- Fallback.
    else
        print("The default branch could not be found for `" .. repo .. "`. Using provided default branch instead.")
        if repos[i].def_branch ~= nil then
            branch = repos[i].def_branch
            print("Found provided default branch for `" .. repo .. "`.")
        else
            print("Could not find provided default branch for `" .. repo .. "`. Skipping.")
            return nil
        end
    end

    -- Remove endline from `branch`. This is causing the subtree command not to squash everything.
    branch = branch:gsub("\n", "")

    return branch
end

--- @brief Gets the branches used
--- when updating the repositories.
--- This is used in the `action.yml` file.
--- @param repos table The table containing all of the repositories.
--- @return nil
function get_repo_branches(repos)
    for i in pairs(repos) do
        print(repos[i].name .. "-update")
    end
end

return {
    check_variables = check_variables,
    get_def_branch = get_def_branch,
    get_repo_branches = get_repo_branches
}
