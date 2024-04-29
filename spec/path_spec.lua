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

describe("`snap.paths`: test paths module", function()
  local mock_env_vars = {
    SNAP = "/snap/ondemand/x1",
    SNAP_COMMON = "/var/snap/ondemand/common",
    SNAP_USER_COMMON = "/root/snap/ondemand/common",
    SNAP_DATA = "/var/snap/ondemand/x1",
    SNAP_USER_DATA = "/root/snap/ondemand/x1",
    SNAP_REAL_HOME = "/root",
  }

  setup(function()
    -- Set mock `SNAP_*` environment variables.
    for k, v in pairs(mock_env_vars) do
      posix.setenv(k, v)
    end

    -- Export mocked `snap` to global namespace.
    _G.snap = require("snap")
  end)

  teardown(function()
    -- Unset mock `SNAP_*` environment variables.
    for k, _ in pairs(mock_env_vars) do
      posix.setenv(k)
    end
  end)

  test("`snap.paths`: test env var accessors", function()
    local snap = _G.snap
    assert.are.equal(snap.paths.snap, "/snap/ondemand/x1")
    assert.are.equal(snap.paths.common, "/var/snap/ondemand/common")
    assert.are.equal(snap.paths.user_common, "/root/snap/ondemand/common")
    assert.are.equal(snap.paths.data, "/var/snap/ondemand/x1")
    assert.are.equal(snap.paths.user_data, "/root/snap/ondemand/x1")
    assert.are.equal(snap.paths.real_home, "/root")
  end)
end)
