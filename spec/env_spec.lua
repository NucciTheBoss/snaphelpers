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

describe("`snap.env`: test env(ironment) module", function()
  local mock_env_vars = {
    SNAP = "/snap/ondemand/x1",
    SNAP_COMMON = "/var/snap/ondemand/common",
    SNAP_USER_COMMON = "/root/snap/ondemand/common",
    SNAP_DATA = "/var/snap/ondemand/x1",
    SNAP_USER_DATA = "/root/snap/ondemand/x1",
    SNAP_REAL_HOME = "/root",
    SNAP_NAME = "ondemand",
    SNAP_INSTANCE_NAME = "ondemand",
    SNAP_INSTANCE_KEY = "",
    SNAP_ARCH = "amd64",
    SNAP_REVISION = "x1",
    SNAP_VERSION = "3.1.1",
    SNAP_UID = "0",
    SNAP_EUID = "0",
    SNAP_LIBRARY_PATH = "/var/lib/snapd/lib/gl:/var/lib/snapd/lib/gl32:/var/lib/snapd/void",
    SNAP_CONTEXT = "2OAKRmgRKBmjJHYSEZgYa2S1HFrd0AvLDV22NW4sKH0hLWtfxuVM",
    SNAP_COOKIE = "2OAKRmgRKBmjJHYSEZgYa2S1HFrd0AvLDV22NW4sKH0hLWtfxuVM",
    SNAP_REEXEC = "",
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

  test("`snap.env`: test env var accessors", function()
    local snap = _G.snap
    assert.are.equal(snap.env.COMMON, "/var/snap/ondemand/common")
    assert.are.equal(snap.env.DATA, "/var/snap/ondemand/x1")
    assert.are.equal(snap.env.REAL_HOME, "/root")
    assert.are.equal(snap.env.SNAP, "/snap/ondemand/x1")
    assert.are.equal(snap.env.USER_COMMON, "/root/snap/ondemand/common")
    assert.are.equal(snap.env.USER_DATA, "/root/snap/ondemand/x1")
    assert.are.equal(snap.env.NAME, "ondemand")
    assert.are.equal(snap.env.INSTANCE_NAME, "ondemand")
    assert.are.equal(snap.env.INSTANCE_KEY, "")
    assert.are.equal(snap.env.ARCH, "amd64")
    assert.are.equal(snap.env.REVISION, "x1")
    assert.are.equal(snap.env.VERSION, "3.1.1")
    assert.are.equal(snap.env.UID, "0")
    assert.are.equal(snap.env.EUID, "0")
    assert.are.equal(snap.env.LIBRARY_PATH, "/var/lib/snapd/lib/gl:/var/lib/snapd/lib/gl32:/var/lib/snapd/void")
    assert.are.equal(snap.env.CONTEXT, "2OAKRmgRKBmjJHYSEZgYa2S1HFrd0AvLDV22NW4sKH0hLWtfxuVM")
    assert.are.equal(snap.env.COOKIE, "2OAKRmgRKBmjJHYSEZgYa2S1HFrd0AvLDV22NW4sKH0hLWtfxuVM")
    assert.are.equal(snap.env.REEXEC, "")
  end)
end)
