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

local data = require(arg[1])
local repos = data.repos
local helper_functions = require("helper-functions")

-- Squash commits option.
local squash_commits
if arg[3] ~= nil then
    squash_commits = arg[3]
else
    squash_commits = false
end

-- One PR option.
local one_pr
if arg[4] ~= nil then
    one_pr = arg[4]
else
    one_pr = false
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

        if one_pr == false then
            os.execute("git checkout -b " .. repos[i].name .. "-update")
        end

        if squash_commits == false then
            os.execute("git commit -m \"Bump " .. repos[i].name .. " to its latest commit\"")
        end

        if one_pr == false then
            os.execute("git push origin " .. repos[i].name .. "-update:" .. repos[i].name .. "-update")
        end

        ::continue::
    end

    if squash_commits == true and one_pr == false then
        os.execute("git commit -m " .. arg[2])
    end
end

-- Update all repositories.
update_repos()
