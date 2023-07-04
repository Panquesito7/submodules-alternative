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

--[[
    Arguments
    [1]: Repositories filename (e.g. `repos`).
    [2]: Whether to squash all the commits or not.
         DISABLED FOR NOW AS IT CAUSES AN ISSUE WITH THE SUBTREES.
    [3]: Commit message that's being used. Only if the squash commits option is enabled.
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

--- @brief Clones all the repositories with the given options.
--- Submodules will be cloned depending on the desired setting.
--- This script can be ran multiple times without any issues.
--- @return nil
local function clone_repos()
    local branch
    local count = 0
    for i = 1, #repos do
        -- Create the given directory if it does not exist.
        os.execute("mkdir -p " .. repos[i].dir)

        -- Make sure the repository is not cloned already.
        if os.execute("test -d " .. repos[i].dir .. repos[i].name) then
            print("Warning: " .. repos[i].dir .. repos[i].name .. " already exists. Skipping.")
            goto continue
        end

        -- Make sure all of the variables are set.
        helper_functions.check_variables(repos, i)

        -- Get the default branch.
        branch = helper_functions.get_def_branch(repos, i) or ""

        if branch == nil then
            goto continue
        end

        os.execute("git subtree add --prefix " .. repos[i].dir .. repos[i].name .. " " .. repos[i].url .. " " .. branch .. " --squash --message \"Add " .. repos[i].name .. ".\"")
        count = count + 1

        ::continue::
    end

    if squash_commits == "true" then
        --os.execute("git reset --soft HEAD~" .. count)
        --os.execute("git commit -m \"" .. arg[3] .. "\"")}
        print("This option has been disabled for now, as it causes an issue with the subtrees preventing them from being updated properly or doing other changes.")
    end
end

-- Clone the given repositories.
clone_repos()
