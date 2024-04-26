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

local env = require("snap.env")
local paths = require("snap.path")
local config = require("snap.config")
local health = require("snap.health")
local services = require("snap.service")
local metadata = require("snap.metadata")

--- Top-level wrapper for a snap package.
---@class snap
---@field name string The snap name.
---@field instance_name string The snap instance name. Usually `name` unless using parallel installs.
---@field version string The snap version.
---@field revision string The snap revision.
local snap = {
  name = env.NAME,
  instance_name = env.INSTANCE_NAME,
  version = env.VERSION,
  revision = env.REVISION,
  env = env,
  paths = paths,
  config = config,
  health = health,
  services = services,
  metadata = metadata
}

return snap
