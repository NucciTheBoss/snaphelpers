-- Copyright 2024 Canonical Ltd.
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License version 3 as published by the Free Software Foundation.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

local yaml = require("lyaml")
local env = require("snap.env")

--- Load a metadata file.
---@param file string Metadata file to load.
---@return table<string, any>
local function load(file)
  local fin = io.open(file, "r")
  if fin == nil then return {} end
  local content = fin:read("*all")
  fin:close()
  return yaml.load(content)
end

local metadata_files = {
  snap = env.SNAP .. "/meta/snap.yaml"
}
local metatable = {
  __index = function(t, key)
    local metadata_file = metadata_files[key]
    if metadata_file == nil then return end
    return load(metadata_file)
  end
}
local metadata = setmetatable({}, metatable)

return metadata
