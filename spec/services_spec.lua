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

describe("`snap.service`: test services module", function()
  local mock_env_vars = {
    SNAP = "/snap/lxd/x1",
    SNAP_NAME = "lxd",
    SNAP_INSTANCE_NAME = "lxd",
    SNAP_VERSION = "5.21.1-10f4115",
    SNAP_REVISION = "28322",
  }

  setup(function()
    -- Set mock `SNAP_*` environment variables.
    for k, v in pairs(mock_env_vars) do
      posix.setenv(k, v)
    end

    -- Export mocked `snap` to global namespace.
    _G.snap = require("snap")

    -- Mock output of `os.capture`.
    stub(os, "capture", function(...)
      return [[Service          Startup  Current   Notes
        lxd.activate     enabled  inactive  -
        lxd.daemon       enabled  active    socket-activated
        lxd.user-daemon  enabled  inactive  socket-activated]]
    end)
  end)

  -- `SnapServices` tests. Wraps all services within the snap.
  test("`snap.service`: test `SnapServices.list()` method", function()
    local snap = _G.snap

    local services = snap.services.list()
    assert.is_table(services)

    local activate = services["activate"]
    assert.is_not_nil(activate)
    assert.are.equal(activate.name, "activate")
    assert.is_true(activate.enabled)
    assert.is_false(activate.active)
    assert.is_nil(next(activate.notes))  -- Ensure that `notes` array is empt.

    local daemon = services["daemon"]
    assert.is_not_nil(daemon)
    assert.are.equal(daemon.name, "daemon")
    assert.is_true(daemon.enabled)
    assert.is_true(daemon.active)
    assert.are.equal(daemon.notes[1], "socket-activated")

    local userdaemon = services["user-daemon"]
    assert.is_not_nil(userdaemon)
    assert.are.equal(userdaemon.name, "user-daemon")
    assert.is_true(userdaemon.enabled)
    assert.is_false(userdaemon.active)
    assert.are.equal(userdaemon.notes[1], "socket-activated")
  end)

  test("`snap.service`: test `SnapServices.start(...)` method", function()
    local snap = _G.snap

    -- Without enabling services at startup.
    snap.services.start()
    assert.stub(os.capture).was.called_with(
      [[/usr/bin/snapctl start lxd]], false
    )

    -- With enabling services at startup.
    snap.services.start(true)
    assert.stub(os.capture).was.called_with(
      [[/usr/bin/snapctl start --enable lxd]], false
    )
  end)

  test("`snap.service`: test `SnapServices.stop(...)` method", function()
    local snap = _G.snap

    -- Without disabling services at startup.
    snap.services.stop()
    assert.stub(os.capture).was.called_with(
      [[/usr/bin/snapctl stop lxd]], false
    )

    -- With disabling services at startup.
    snap.services.stop(true)
    assert.stub(os.capture).was.called_with(
      [[/usr/bin/snapctl stop --disable lxd]], false
    )
  end)

  test("`snap.service`: test `SnapServices.restart(...)` method", function()
    local snap = _G.snap

    -- Without reloading services.
    snap.services.restart()
    assert.stub(os.capture).was.called_with(
      [[/usr/bin/snapctl restart lxd]], false
    )

    -- With reloading services.
    snap.services.restart(true)
    assert.stub(os.capture).was.called_with(
      [[/usr/bin/snapctl restart --reload lxd]], false
    )
  end)

  -- `SnapService` tests. Wraps a single service within the snap.
  test("`snap.service`: test `SnapService:start(...)` method", function()
    local snap = _G.snap
    local daemon = snap.services.list()["daemon"]
    stub(daemon, "refresh_status")  -- `refresh_status` interferes with `.called_with(...)`.

    -- Without enabling the service at startup.
    daemon:start()
    assert.stub(os.capture).was.called_with(
      [[/usr/bin/snapctl start lxd.daemon]], false
    )

    -- With disabling the service at startup.
    daemon:start(true)
    assert.stub(os.capture).was.called_with(
      [[/usr/bin/snapctl start --enable lxd.daemon]], false
    )
  end)

  test("`snap.service`: test `SnapService:stop(...)` method", function()
    local snap = _G.snap
    local daemon = snap.services.list()["daemon"]
    stub(daemon, "refresh_status")  -- `refresh_status` interferes with `.called_with(...)`

    -- Without disabling the service at startup.
    daemon:stop()
    assert.stub(os.capture).was.called_with(
      [[/usr/bin/snapctl stop lxd.daemon]], false
    )

    -- With disabling the service at startup.
    daemon:stop(true)
    assert.stub(os.capture).was.called_with(
      [[/usr/bin/snapctl stop --disable lxd.daemon]], false
    )
  end)

  test("`snap.service`: test `SnapService:restart(...)` method", function()
    local snap = _G.snap
    local daemon = snap.services.list()["daemon"]
    stub(daemon, "refresh_status")  -- `refresh_status` interferes with `.called_with(...)`

    -- Without reloading the service.
    daemon:restart()
    assert.stub(os.capture).was.called_with(
      [[/usr/bin/snapctl restart lxd.daemon]], false
    )

    -- With reloading the service.
    daemon:restart(true)
    assert.stub(os.capture).was.called_with(
      [[/usr/bin/snapctl restart --reload lxd.daemon]], false
    )
  end)

  test("`snap.servcie`: test `SnapService:refresh_status()` method", function()
    local snap = _G.snap
    local activate = snap.services.list()["activate"]
    activate:refresh_status()
    assert.stub(os.capture).was.called_with(
      [[/usr/bin/snapctl services lxd.activate]], false
    )
  end)
end)
