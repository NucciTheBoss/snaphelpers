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

---@class SnapHealth
local SnapHealth = {}

--- Create a new `SnapHealth` object.
---@return SnapHealth
function SnapHealth:new()
  local snaphealth = setmetatable({}, self)
  self.__index = self
  return snaphealth
end

--- Set snap health status to `okay`.
function SnapHealth.okay()
  ctl:set_health("okay")
end

--- Set snap health status to `waiting`.
---@param msg string Message to set for waiting status.
function SnapHealth.waiting(msg)
  ctl:set_health("waiting", msg)
end

--- Set snap health status to `blocked`.
---@param msg string Message to set for blocked status.
function SnapHealth.blocked(msg)
  ctl:set_health("blocked", msg)
end

--- Set snap health status to `error`.
---@param msg string Message to set for error status.
function SnapHealth.error(msg)
  ctl:set_health("error", msg)
end

return SnapHealth:new()
