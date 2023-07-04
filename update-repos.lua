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

--- @brief Updates all the repositories by
--- running `git pull` on each repository.
--- Nothing will be done if the repositories are not behind the remote.
--- @return nil
local function update_repos()
    for i = 1, #repos do
        -- Make sure all of the variables are set.
        helper_functions.check_variables(repos, i)

        -- Make sure the repository is cloned already.
        if os.execute("test -d " .. repos[i].dir .. repos[i].name) == nil then
            print("Warning: " .. repos[i].dir .. repos[i].name .. " does not exist. Skipping.")
            goto continue
        end

        -- Attempt to get the default branch.
        local branch = helper_functions.get_def_branch(repos, i)

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

        os.execute("git checkout --theirs .")
        os.execute("git add " .. repos[i].dir .. repos[i].name)

        if one_pr == "false" then
            os.execute("git branch " .. repos[i].name .. "-update")
        end

        if squash_commits == "false" then
            os.execute("git commit -m \"Bump " .. repos[i].name .. " to its latest commit\"")
        end

        if one_pr == "false" and squash_commits == "false" then
            os.execute("git push origin " .. repos[i].name .. "-update:" .. repos[i].name .. "-update")
        end

        ::continue::
    end

    if squash_commits == "true" and one_pr == "true" then
        os.execute("git commit -m \"" .. arg[4] .. "\"")
    end
end

-- Update all repositories.
update_repos()
