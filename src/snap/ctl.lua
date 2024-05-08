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

local json = require("cjson")
local env = require("snap.env")

--- Execute command using operating system shell and capture the output.
---@param cmd string Command to execute using operating shell.
---@param raw boolean If `true`, return raw output of command. Default: `false`.
---@return string
---@private
function os.capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  -- Trim extra commonly found at the end of command output.
  s = string.gsub(s, "\n[^\n]*$", "")
  return s
end

--- Format configuration options for setting by `snapctl`.
---@param config table<string, any> Configuration options to format. Keys can use dot notation.
---@return string[]
local function set_args(config)
  local set = {}
  for k, v in pairs(config) do
    table.insert(set, string.format("%s='%s'", k, json.encode(v)))
  end
  return set
end

--- Format configuration keys for unsetting by `snapctl`.
---@param ... string Keys to format for unsetting.
---@return string[]
local function unset_args(...)
  local unset = {}
  for _, key in ipairs{...} do
    table.insert(unset, string.format("%s!", key))
  end
  return unset
end

--- Wrapper around the `snapctl` executable.
---@class SnapCtl
local SnapCtl = {}

--- Create a new `SnapCtl` object.
---@return SnapCtl
function SnapCtl:new()
  local snapctl = setmetatable({}, self)
  self.__index = self
  return snapctl
end

--- Start all or specified service within the snap.
---@param service string | nil Service to start. If no is service is provided, start all services.
---@param enable boolean | nil Wether to enable the service(s) at startup.
function SnapCtl:start(service, enable)
  self:run_services("start", service, { enable = enable })
end

--- Stop all or specified service within the snap.
---@param service string | nil Service to stop. If no service is provided, stop all services.
---@param disable boolean | nil Whether to disable the service(s) at startup.
function SnapCtl:stop(service, disable)
  self:run_services("stop", service, { disable = disable })
end

--- Restart all or specified service within the snap.
---@param service string | nil Service to restart. If no service is provided, restart all services.
---@param reload boolean | nil Whether to reload the service(s) if supported.
function SnapCtl:restart(service, reload)
  self:run_services("restart", service, { reload = reload })
end

---Retrieve information about a service inside the snap.
---@param name string | nil Name of service to get info for. If `nil`, get info for all services.
---@return table[]
function SnapCtl:services(name)
  local s_infos = {}

  local out = self:run_services("services", name)
  -- Remove header "Service  Startup  Current  Notes".
  local services = out:gsub("^[^\n]*\n", "")
  -- Unmarshall service information collected from `snapctl`.
  for s in string.gmatch(services, "[^\r\n]+") do
    local info = {}
    for d in string.gmatch(s, "[^%s]+") do
      table.insert(info, d)
    end -- Iterate over line with whitespace separator `[^%s]`.

    local notes = {}
    if info[4] ~= "-" then
      for n in string.gmatch(info[4], "[^,]+") do
        table.insert(notes, n)
      end
    end
    local s_info = {
      name = string.match(info[1], "[.](%S+)"),
      enabled = info[2] == "enabled",
      active = info[3] == "active",
      notes = notes
    }
    table.insert(s_infos, s_info)
  end -- Iterate over multiline string with newline separator `[^\r\n]+`.

  return s_infos
end

--- Get snap configuration.
---@param ... string Keys to get from snap configuration.
---@return table<string, any>
function SnapCtl:config_get(...)
  local cmd = { "get", "-d" }
  for _, key in ipairs{...} do
    table.insert(cmd, key)
  end

  local out = self.run(cmd)
  return json.decode(out)
end

--- Set snap configuration.
---@param config table<string, any> Keys to set in snap configuration. Keys can use dot notation.
function SnapCtl:config_set(config)
  local cmd = { "set" }
  for _, key in ipairs(set_args(config)) do
    table.insert(cmd, key)
  end
  self.run(cmd)
end

--- Unset snap configuration.
---@param ... string Keys to unset in snap configuration.
function SnapCtl:config_unset(...)
  local cmd = { "unset" }
  for _, key in ipairs(unset_args(...)) do
    table.insert(cmd, key)
  end
  self.run(cmd)
end

--- Set snap health status.
---@param status string Snap health status.
---@param msg string | nil Message for snap health status.
function SnapCtl:set_health(status, msg)
  local cmd = { "set-health", status }
  if msg then table.insert(cmd, msg) end
  self.run(cmd)
end

--- Run a `snapctl` command on a given service.
---@param action string "Action to perform on service."
---@param service string | nil "Service to perform action. If `nil`, perform action on all services."
---@param option table | nil "Option to apply to service."
---@return string
---@private
function SnapCtl:run_services(action, service, option)
  local cmd = { action }

  if option then
    for k, v in pairs(option) do
      if v then table.insert(cmd, string.format("--%s", k)) end
    end
  end

  if service then
    table.insert(cmd, string.format("%s.%s", env.INSTANCE_NAME, service))
  else
    table.insert(cmd, env.INSTANCE_NAME)
  end

  return self.run(cmd)
end

--- Run a `snapctl` command and return its output.
---@param args string[] Arguments to pass to `snapctl`.
---@return string
---@private
function SnapCtl.run(args)
  local cmd = "/usr/bin/snapctl " .. table.concat(args, " ")
  return os.capture(cmd, false)
end

return SnapCtl:new()
