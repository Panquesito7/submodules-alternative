--
-- Updates all repositories in the given time.
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

--[[
    Arguments
    [1]: Repositories filename (e.g. `repos`).
    [2]: Whether to squash all the commits or not.
    [3]: One PR option, which uses multiple branches if disabled.
         The action workflow takes care of this in case this option is enabled.
    [4]: Commit message (only if `squash_commits` is enabled).
         Cannot be used if `one_pr` is disabled.
--]]

if os.getenv("GITHUB_ACTION_PATH") ~= nil then
    package.path = os.getenv("GITHUB_ACTION_PATH") .. "/src/?.lua;" .. package.path
end

local data = require(arg[1])
local repos = data.repos
local helper_functions = require("helper-functions")

-- Squash commits option.
local squash_commits
if arg[2] ~= nil then
    squash_commits = arg[2]
else
    squash_commits = "false"
end

-- One PR option.
local one_pr
if arg[3] ~= nil then
    one_pr = arg[3]
else
    one_pr = "false"
end

-- Commit message option.
local commit_message
if arg[4] ~= nil then
    commit_message = arg[4]
else
    commit_message = 'Bump repositories to their latest version'
end

--- @brief Updates all the repositories by
--- running `git pull` on each repository.
--- Nothing will be done if the repositories are not behind the remote.
--- @return nil
local function update_repos()
    for i = 1, #repos do
        -- Make sure all of the variables are set.
        helper_functions.check_variables(repos[i])

        -- Make sure the repository is cloned already.
        local command = (helper_functions.is_on_windows() == false and "test -d " .. repos[i].dir .. repos[i].name)
        or "if exist " .. repos[i].dir .. repos[i].name .. " (exit 1) else (exit 0)"

        if os.execute(command) == (nil or 1) then
            print("Warning: " .. repos[i].dir .. repos[i].name .. " does not exist. Skipping.")
            goto continue
        end

        -- Attempt to get the default branch.
        local branch = helper_functions.get_def_branch(repos[i]) or ""

        if branch == nil then
            goto continue
        end

        os.execute("git remote add -f " .. repos[i].name .. " " .. repos[i].url)
        os.execute("git merge -s subtree --squash --allow-unrelated-histories -Xsubtree=" .. repos[i].dir .. repos[i].name .. " " .. repos[i].name .. "/" .. branch)
        os.execute("git remote remove " .. repos[i].name)

        -- Is the repository already up-to-date?
        if os.execute("git diff --quiet HEAD " .. repos[i].dir .. repos[i].name) then
            print("Warning: " .. repos[i].name .. " is already up to date. Skipping.")
            goto continue
        end

        os.execute("git checkout --theirs " .. repos[i].dir .. repos[i].name)
        os.execute("git add " .. repos[i].dir .. repos[i].name)

        local updated_repos = io.open("updated_repos.txt", "w+")
        if updated_repos then
            updated_repos:write("")
            updated_repos:close()
        end

        updated_repos = io.open("updated_repos.txt", "a+")
        if updated_repos then
            updated_repos:write(repos[i].name .. "\n")
            updated_repos:close()
        end

        if one_pr == "false" then
            local default_branch = io.popen("git remote show origin | grep \"HEAD branch\" | cut -d' ' -f5"):read("*a")

            if default_branch then
                default_branch = default_branch:gsub("\n", "")
                os.execute("git checkout " .. default_branch)
            else
                print("Error: Could not get the default branch of the current repository.")
                goto continue
            end

            -- Create a new branch.
            os.execute("git checkout -b " .. repos[i].name .. "-update")
        end

        if squash_commits == "false" then
            os.execute("git commit -m 'Bump `" .. repos[i].name .. "` to its latest commit'")
        end

        if one_pr == "false" and squash_commits == "false" then
            os.execute("git push origin " .. repos[i].name .. "-update:" .. repos[i].name .. "-update")
        end

        ::continue::
    end

    if squash_commits == "true" and one_pr == "true" then
        os.execute("git commit -m '" .. commit_message .. "'")
    end
end

local updated_repos = io.open("updated_repos.txt", "a+")
if updated_repos then
    updated_repos:write("\n")
end

-- Update all repositories.
update_repos()
