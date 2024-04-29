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
local yaml = require("lyaml")

describe("`snap.metadata`: test metadata module", function()
  setup(function()
    -- Mock $SNAP env var to $PWD.
    posix.setenv("SNAP", posix.getcwd())

    -- Export mocked `snap` to global namespace.
    _G.snap = require("snap")

    -- Create mock `meta/snap.yaml` from ondemand snap package.
    posix.mkdir(posix.getcwd() .. "/meta")
    local fout = io.open("meta/snap.yaml", "w+")
    if fout == nil then return end
    fout:write(
      yaml.dump(
        { {
          apps = {
            ondemand = {
              command = "sbin/httpd.wrapper -k start -DFOREGROUND",
              daemon = "simple",
              ["install-mode"] = "disable",
              ["restart-condition"] = "on-abort",
              ["stop-command"] = "sbin/httpd.wrapper -k graceful-stop"
            },
            ["update-ood-portal"] = {
              command = "sbin/update-ood-portal.wrapper"
            }
          },
          architectures = {
            "amd64"
          },
          base = "core22",
          confinement = "classic",
          description =
          [[Open OnDemand empowers students, researchers, and industry professionals with remote web access to supercomputers, high-performance computing clusters, and computational grids.
        ]],
          environment = {
            GEM_PATH =
            "$SNAP/gems:$SNAP/usr/lib/ruby/gems:$SNAP/usr/share/rubygems-integration/all/gems:$SNAP/var/lib/gems",
            PATH = "$SNAP/usr/sbin:$SNAP/usr/bin:$SNAP/sbin:$SNAP/bin:$SNAP/usr/local/bin:$SNAP/usr/local/sbin:$PATH",
            RUBYLIB =
            "$SNAP/usr/lib/ruby/3.0.0:$SNAP/usr/lib/ruby/gems/3.0.0:$SNAP/usr/lib/x86_64-linux-gnu/ruby/3.0.0:$SNAP/usr/lib/ruby/vendor_ruby/3.0.0:$SNAP/gems/extensions/x86_64-linux/3.0.0:$SNAP/usr/lib/x86_64-linux-gnu/ruby/vendor_ruby/3.0.0:$SNAP/var/lib/gems/3.0.0:$SNAP/opt/passenger/lib/ruby/3.0.0"
          },
          grade = "devel",
          license = "MIT",
          links = {
            website = {
              "https://openondemand.org"
            }
          },
          name = "ondemand",
          summary = "Open, interactive High-Performance Computing via the web.",
          ["system-usernames"] = {
            snap_daemon = "shared"
          },
          title = "Open OnDemand",
          version = "3.1.1"
        } }
      )
    )
    fout:close()
  end)

  teardown(function()
    posix.unlink(posix.getcwd() .. "/meta/snap.yaml")
    posix.rmdir(posix.getcwd() .. "/meta")
  end)

  test("`snap.metadata`: test metadata file accessors", function()
    local snap = _G.snap

    local metadata = snap.metadata.snap
    assert.is_table(metadata)
    assert.are.equal(metadata.name, "ondemand")
    assert.are.equal(metadata.base, "core22")
    assert.are.equal(metadata.architectures[1], "amd64")
    assert.are.equal(metadata["system-usernames"]["snap_daemon"], "shared")
  end)
end)
