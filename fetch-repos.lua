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

--package.path = package.path .. ";../?.lua"
local data = require(arg[1])

local repos = data.repos
local check_variables = require("check-variables").check_variables

--- @brief Clones all the repositories with the given options.
--- Submodules will be cloned depending on the desired setting.
--- This script can be ran multiple times without any issues.
--- @return nil
local function clone_repos()
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

        -- Clone the repository with the given options.
        if repos[i].clone_modules == true or repos[i].clone_modules == nil then
            os.execute("git clone --recursive " .. repos[i].url .. " " .. repos[i].dir .. repos[i].name)
        elseif repos[i].clone_modules == false then
            --os.execute("git clone " .. repos[i].url .. " " .. repos[i].dir .. repos[i].name)
        end

        ::continue::
    end
end

-- Clone the given repositories.
clone_repos()
