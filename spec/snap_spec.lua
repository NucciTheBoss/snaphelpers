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

describe("`snap`: test module entrypoint", function()
  local mock_env_vars = {
    SNAP = "/snap/ondemand/x1",
    SNAP_NAME = "ondemand",
    SNAP_INSTANCE_NAME = "ondemand",
    SNAP_VERSION = "3.1.1",
    SNAP_REVISION = "x1",
  }

  setup(function()
    -- Set mock `SNAP_*` environment variables.
    for k, v in pairs(mock_env_vars) do
      posix.setenv(k, v)
    end

    -- Export mocked `snap` to global namespace.
    _G.snap = require("snap")
  end)

  test("`snap`: test `Snap` object attributes", function()
    local snap = _G.snap
    assert.are.equal(snap.name, "ondemand")
    assert.are.equal(snap.instance_name, "ondemand")
    assert.are.equal(snap.version, "3.1.1")
    assert.are.equal(snap.revision, "x1")
  end)
end)
