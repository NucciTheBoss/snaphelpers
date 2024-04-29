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

local ctl = require("snap.ctl")

--- Crawl down a dot notation key to get the most nested sub-key.
---@param config table<string, any> Snap configuration information.
---@param key string The dot notation key to crawl down.
---@return any
local function crawl(config, key)
  local target = config
  local keys = {}
  -- Unmarshall `snap.key` notation into an array of sub-keys
  for k in string.gmatch(key, "[^.]+") do
    table.insert(keys, k)
  end

  -- Crawl down snap configuration until most nested key is reached.
  local last = ""
  local i_last = #keys
  for i, k in ipairs(keys) do
    if i == i_last then
      last = k
    else
      target = target[k]
    end
  end

  return target[last]
end

---@class SnapConfig
local SnapConfig = {}

--- Create a new `SnapConfig` object.
---@return SnapConfig
function SnapConfig:new()
  local snapconfig = setmetatable({}, self)
  self.__index = self
  return snapconfig
end

--- Get value for given snap configuration options.
---@param ... string Configuration options to retrieve.
---@return table<string, any>
function SnapConfig:get_options(...)
  local config = {}
  for _, k in ipairs(arg) do
    local c = self.get(k)
    local target = string.match(k, "[^.]+$")  -- If sub-key, get deepest nested key.
    config[target] = c
  end
  return config
end

--- Get value for snap configuration option.
---@param key string Configuration option to retrieve.
---@return any
function SnapConfig.get(key)
  local top_key = string.match(key, "[^.]+")
  local config = ctl:config_get(top_key)
  return crawl(config, key)
end

--- Set snap configuration options.
---@param config table<string, any> Configuration options to set. Keys can use dot notation.
function SnapConfig.set(config)
  ctl:config_set(config)
end

--- Unset snap configuration options.
---@param ... string Configuration keys to unset.
function SnapConfig.unset(...)
  ctl:config_unset(...)
end

return SnapConfig:new()
