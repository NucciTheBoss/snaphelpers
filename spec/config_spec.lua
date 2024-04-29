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

describe("`snap.config`: test config module", function()
  setup(function()
    -- Set mock `SNAP` env var. Required by the `snap.metadata` module.
    posix.setenv("SNAP", "/snap/ondemand/x1")

    -- Export mocked `snap` to global namespace.
    _G.snap = require("snap")

    -- Mock output of `os.capture`.
    stub(os, "capture", function(...)
      return [[{
        "portal": {
            "auth": [
                "AuthType openid-connect",
                "Require valid-user"
            ],
            "oidc_uri": "/oidc",
            "oidc_redirect_uri": "/oidc",
            "oidc_provider_metadata_url": "http://10.155.150.244/dex/.well-known/openid-configuration",
            "oidc_client_id": "10.155.150.244",
            "oidc_client_secret": "4df1418b-e986-40d6-a0dc-9ee0ddb807b4",
            "oidc_remote_user_claim": "preferred_username",
            "oidc_scope": "openid profile email",
            "dex": {
                "uri": "/dex",
                "http_port": 5551
            },
            "user_map_match": ".*",
            "logroot": "/var/snap/ondemand/common/var/log/ood",
            "lua_root": "/snap/ondemand/x1/mod_ood_proxy/lib",
            "lua_log_level": "debug",
            "public_root": "/var/snap/ondemand/common/var/www/ood/public",
            "pun_socket_root": "/var/snap/ondemand/common/run/nginx",
            "pun_stage_cmd": "sudo /snap/ondemand/x1/nginx_stage/sbin/nginx_stage"
        }
      }]]
    end)
  end)

  test("`snap.config`: test `get` method", function()
    local snap = _G.snap

    -- Get value of top-level snap configuration key.
    local portal = snap.config.get("portal")
    assert.is_table(portal)
    assert.are_equal(portal.pun_stage_cmd, "sudo /snap/ondemand/x1/nginx_stage/sbin/nginx_stage")
    assert.are_equal(portal.dex.uri, "/dex")
    assert.are.equal(portal.auth[1], "AuthType openid-connect")
    assert.are.equal(portal.auth[2], "Require valid-user")

    -- Get value of nested snap configuration key.
    local pun_socket_root = snap.config.get("portal.pun_socket_root")
    local oidc_remote_user_claim = snap.config.get("portal.oidc_remote_user_claim")
    assert.are.equal(pun_socket_root, "/var/snap/ondemand/common/run/nginx")
    assert.are.equal(oidc_remote_user_claim, "preferred_username")
  end)

  test("`snap.config`: test `get_options` method", function()
    local snap = _G.snap

    -- Get snap configuration options using both top-level and sub-keys.
    local config = snap.config:get_options("portal", "portal.logroot", "portal.lua_log_level")
    assert.is_table(config)
    assert.are.equal(config.portal.user_map_match, ".*")
    assert.are.equal(config.portal.oidc_scope, "openid profile email")
    assert.are.equal(config.logroot, "/var/snap/ondemand/common/var/log/ood")
    assert.are.equal(config.lua_log_level, "debug")
  end)

  test("`snap.config`: test `set` method", function()
    local snap = _G.snap

    -- Check that `snapctl` is invoked correctly by `os.capture`.
    snap.config.set({ ["portal.dex.uri"] = "/dex", ["portal.dex.http_port"] = "5551" })
    assert.stub(os.capture).was.called_with(
      [[/usr/bin/snapctl set portal.dex.http_port='"5551"' portal.dex.uri='"\/dex"']], false
    )

    -- Ensure that arrays are properly escaped before passing to `snapctl`.
    snap.config.set({ ["portal.auth"] = { "AuthType openid-connect", "Require valid-user" } })
    assert.stub(os.capture).was.called_with(
      [[/usr/bin/snapctl set portal.auth='["AuthType openid-connect","Require valid-user"]']], false
    )
  end)

  test("`snap.config`: test `unset` method", function()
    local snap = _G.snap

    -- Check that snapctl is invoked correctly by `os.capture`.
    snap.config.unset("portal.auth", "portal.dex", "portal")
    assert.stub(os.capture).was.called_with(
      [[/usr/bin/snapctl unset portal.auth! portal.dex! portal!]], false
    )
  end)
end)
