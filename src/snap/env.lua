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

local posix = require("posix")

local env = {}

-- Load $SNAP_* envvars into env table.
for k, v in pairs(posix.getenv()) do
  if string.match(k, "^SNAP_") then
    local _k = string.gsub(k, "^SNAP_", "")
    env[_k] = v
  end
end

-- Manually add $SNAP envvar to env table since it fails the env match.
env["SNAP"] = posix.getenv("SNAP")

return env
