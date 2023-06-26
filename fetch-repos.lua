--
-- Obtains the data from the configuration file and clones the given repositories.
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

local data = require(arg[1])
local repos = data.repos
local check_variables = require("check-variables").check_variables

--- @brief Clones all the repositories with the given options.
--- Submodules will be cloned depending on the desired setting.
--- This script can be ran multiple times without any issues.
--- @return nil
local function clone_repos()
    local branch = ""
    for i = 1, #repos do
        -- Make sure all of the variables are set.
        check_variables(repos, i)

        -- Create the given directory if it does not exist.
        os.execute("mkdir -p " .. repos[i].dir)

        -- Make sure the repository is not cloned already.
        if os.execute("test -d " .. repos[i].dir .. repos[i].name) then
            print("Warning: " .. repos[i].dir .. repos[i].name .. " already exists. Skipping.")
            goto continue
        end

        -- Get the current VCS that is being used.
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
            end
        -- Fallback.
        else
            print("The default branch could not be found for `" .. repo .. "`. Using provided default branch instead.")
            if repos[i].def_branch ~= nil then
                branch = repos[i].def_branch
                print("Found provided default branch for `" .. repo .. "`.")
            else
                print("Could not find provided default branch for `" .. repo .. "`. Skipping.")
                goto continue
            end
        end

        -- Remove endline from `branch`. This is causing the subtree command not to squash everything.
        branch = branch:gsub("\n", "")

        -- Use `git subtree` to avoid the repo being converted to a submodule.
        os.execute("git subtree add --prefix " .. repos[i].dir .. repos[i].name .. " " .. repos[i].url .. " " .. branch .. " --squash")

        -- Change the commit message to include the repository name, only, if the commit was successful.
        if os.execute("test -d " .. repos[i].dir .. repos[i].name) then
            os.execute("git commit --amend -m \"Add " .. repos[i].name .. " repository\"")
        end

        ::continue::
    end
end

-- Clone the given repositories.
clone_repos()
