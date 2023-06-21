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
        if os.execute("test -d " .. repos[i].dir .. repos[i].name) == 0 then
            print("Warning: " .. repos[i].dir .. repos[i].name .. " already exists. Skipping.")
            goto continue
        end

        -- Obtain the default branch name from the given URL by using `git remote show`.
        local handle = io.popen("git ls-remote --heads " .. repos[i].url .. " | grep -v HEAD | cut -d'/' -f3")
        if handle then
            branch = handle:read("*a")
            handle:close()
        end

        -- Use `git subtree` to avoid the repo being converted to a submodule.
        os.execute("git subtree add --prefix " .. repos[i].dir .. repos[i].name .. " " .. repos[i].url .. " " .. branch .. " --squash")

        ::continue::
    end
end

-- Clone the given repositories.
clone_repos()
