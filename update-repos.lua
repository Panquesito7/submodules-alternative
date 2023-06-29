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
local check_variables = require("check-variables").check_variables

--- @brief Updates all the repositories by
--- running `git pull` on each repository.
--- Nothing will be done if the repositories are not behind the remote.
--- @return nil
local function update_repos()
    for i = 1, #repos do
        -- Make sure all of the variables are set.
        check_variables(repos, i)

        -- Make sure the repository is cloned already.
        if os.execute("test -d " .. repos[i].dir .. repos[i].name) == nil then
            print("Warning: " .. repos[i].dir .. repos[i].name .. " does not exist. Skipping.")
            goto continue
        end

        -- Update the repository with the given options.
        os.execute("cd " .. repos[i].dir .. repos[i].name .. " && git pull && git add .")
        ::continue::
    end

    os.execute("git commit -m " .. arg[2])
end

-- Update all repositories.
update_repos()
