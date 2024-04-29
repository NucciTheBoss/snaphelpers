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

---@class SnapService
local SnapService = {}
SnapService.__index = SnapService

--- Create a new `SnapService` object.
---@param t table<string, any> Current info about the snap service.
---@return SnapService
function SnapService:new(t)
  local service = {}
  setmetatable(service, SnapService)

  service.name = t.name
  service.enabled = t.enabled
  service.active = t.active
  service.notes = t.notes

  return service
end

--- Start the snap service.
---@param enable boolean | nil "Whether to enable the snap service at startup. Default: `false`."
function SnapService:start(enable)
  ctl:start(self.name, enable)
  self:refresh_status()
end

--- Stop the snap service.
---@param disable boolean | nil "Whether to disable the snap service at startup. Default: `false`."
function SnapService:stop(disable)
  ctl:stop(self.name, disable)
  self:refresh_status()
end

--- Restart the snap service.
---@param reload boolean | nil "Reload the snap service if supported. Default: `false`."
function SnapService:restart(reload)
  ctl:restart(self.name, reload)
  self:refresh_status()
end

--- Refresh the current status of the snap service.
function SnapService:refresh_status()
  local s_info = ctl:services(self.name)[1] -- Only one index is returned.
  self.name = s_info.name
  self.enabled = s_info.enabled
  self.active = s_info.active
  self.notes = s_info.notes
end

---@class SnapServices
local SnapServices = {}

--- Create a new `SnapServices` object.
---@return SnapServices
function SnapServices:new()
  local snapservices = setmetatable({}, self)
  self.__index = self
  return snapservices
end

--- Get all snap services by name.
---@return { [string]: SnapService }
function SnapServices.list()
  local services = {}
  for _, s in ipairs(ctl:services()) do
    services[s.name] = SnapService:new(s)
  end
  return services
end

--- Start all snap services.
---@param enable boolean | nil "If `true`, enable all services at startup. Default: `false`."
function SnapServices.start(enable)
  ctl:start(nil, enable)
end

--- Stop all snap services.
---@param disable boolean | nil "If `true`, disable all services at startup. Default: `false`."
function SnapServices.stop(disable)
  ctl:stop(nil, disable)
end

--- Restart all snap services.
---@param reload boolean | nil "If `true`, reload all services if supported. Default: `false`."
function SnapServices.restart(reload)
  ctl:restart(nil, reload)
end

return SnapServices:new()
