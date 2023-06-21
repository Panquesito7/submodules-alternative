--
-- Helper function that verifies that all the variables for the repositories are set.
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
end

return {
    check_variables = check_variables
}
