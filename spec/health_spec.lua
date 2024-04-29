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

describe("`snap.health`: test health module", function()
  setup(function()
    -- Set mock `SNAP` env var. Required by the `snap.metadata` module.
    posix.setenv("SNAP", "/snap/ondemand/x1")

    -- Export mocked `snap` to global namespace.
    _G.snap = require("snap")

    -- Mock `os.capture`. No out required for this test suite.
    stub(os, "capture")
  end)

  test("`snap.health`: test `SnapHealth.okay()` method", function()
    local snap = _G.snap
    snap.health.okay()

    assert.stub(os.capture).was.called_with(
      [[/usr/bin/snapctl set-health okay]], false
    )
  end)

  test("`snap.health`: test `SnapHealth.waiting(...)` method", function()
    local snap = _G.snap

    snap.health.waiting("waiting for slurm cluster")
    assert.stub(os.capture).was.called_with(
      [[/usr/bin/snapctl set-health waiting waiting for slurm cluster]], false
    )
  end)

  test("`snap.health`: test `SnapHealth.block(...)` method", function()
    local snap = _G.snap

    snap.health.blocked("missing configuration file")
    assert.stub(os.capture).was.called_with(
      [[/usr/bin/snapctl set-health blocked missing configuration file]], false
    )
  end)

  test("`snap.health`: test `SnapHealth.error(...)` method", function()
    local snap = _G.snap

    snap.health.error("unable to start httpd service")
    assert.stub(os.capture).was.called_with(
      [[/usr/bin/snapctl set-health error unable to start httpd service]], false
    )
  end)
end)
