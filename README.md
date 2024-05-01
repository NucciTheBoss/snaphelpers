<div align="center">

# snaphelpers

A [Lua](https://www.lua.org) module for interfacing with the snap subsystem
from within a [snap](https://snapcraft.io/about). Level up your hooks
and wrappers by being able to quickly access configuration options and
application properties without requiring a smörgåsbord of complex
and difficult to maintain shell scripts!

</div>

## But why?

Why did I make a module for creating snap hooks using the Lua programming
language when the posix shell hooks already exist, and there's already
utilities for writing snap hooks in other programming languages such as Python?
Well, first, I once listened to a lightning talk where I was told to stop
writing complicated shell scripts - I took that to heart - and second,
there's a few benefits to using Lua-based snap hooks instead of Python-based hooks:

* Lua is fast, minimalistic, and has a small memory footprint.
* Lua is easy to embed inside snaps.
* Lua scripts are easy to test, cover, and debug compared to shell scripts.
* The Lua interpreter is easy to customise; no need for virtual environments and dark magic to obscure complexity behind venv's. You can modify where Lua looks for packages on your system directly within Lua scripts, before the third-party module is loaded.

This module provides a seemless experience for writing snap hooks and
application wrappers in Lua, and have feature parity with the
[snap-helpers](https://github.com/albertodonato/snap-helpers) Python
package.

## Usage

### Access basic information about the installed snap

```lua
local snap = require("snap")

snap.name -- "ondemand"
snap.instance_name -- "ondemand"
snap.version -- "3.1.4"
snap.revision -- "x1"
```

### Access snap-related paths

```lua
local snap = require("snap")

snap.paths.snap -- "/snap/ondemand/x1",
snap.paths.common -- "/var/snap/ondemand/common",
snap.paths.user_common -- "/root/snap/ondemand/common",
snap.paths.data -- "/var/snap/ondemand/x1",
snap.paths.user_data -- "/root/snap/ondemand/x1",
snap.paths.real_home -- "/root",
```

### Access enivornment variables

```lua
local snap = require("snap")

snap.env.COMMON -- "/var/snap/ondemand/common"
snap.env.DATA -- "/var/snap/ondemand/x1"
snap.env.REAL_HOME -- "/root"
snap.env.SNAP -- "/snap/ondemand/x1"
snap.env.USER_COMMON -- "/root/snap/ondemand/common"
snap.env.USER_DATA -- "/root/snap/ondemand/x1"
snap.env.NAME -- "ondemand"
snap.env.INSTANCE_NAME -- "ondemand"
snap.env.INSTANCE_KEY -- ""
snap.env.ARCH -- "amd64"
snap.env.REVISION -- "x1"
snap.env.VERSION -- "3.1.1"
snap.env.UID -- "0"
snap.env.EUID -- "0"
snap.env.LIBRARY_PATH -- "/var/lib/snapd/lib/gl:/var/lib/snapd/lib/gl32:/var/libsnapd/void"
snap.env.CONTEXT -- "2OAKRmgRKBmjJHYSEZgYa2S1HFrd0AvLDV22NW4sKH0hLWtfxuVM"
snap.env.COOKIE -- "2OAKRmgRKBmjJHYSEZgYa2S1HFrd0AvLDV22NW4sKH0hLWtfxuVM"
snap.env.REEXEC -- ""
```

### Manage configuration options

```lua
local snap = require("snap")

-- Get a specific configuration option.
local portal = snap.config.get("portal")
portal.user_map_match -- ".*"
portal.dex.uri -- "/dex"
portal.auth[1], -- "AuthType openid-connect"
portal.auth[2], -- "Require valid-user"

-- Get multiple configuration options.
local cfg = snap.config:get_options("portal", "nginx-stage")
cfg.portal.oidc_scope -- "openid profile email"
cfg.portal.oidc_remote_user_claim -- "preferred_username"
cfg["nginx-stage"].passenger_ruby -- "/usr/bin/ruby"
cfg["nginx-stage"].passenger_python -- "/usr/bin/python3"

-- Set configuration options.
snap.config.set(
  {
    ["portal.dex.uri"] = "/dex",
    ["portal.dex.http_port"] = "5551"
  }
)

-- Unset configuration options.
snap.config.unset("portal.auth", "portal.dex")
```

### Control services

```lua
local snap = require("snap")

-- Control all services within the snap.
snap.services.start() -- Start all services.
snap.services.stop() -- Stop all services.
snap.services.restart() -- Restart all services.

-- Get info about a specific service within the snap.
local ondemand = snap.services.list().ondemand
ondemand.name -- "ondemand"
ondemand.enabled -- false
ondemand.active -- true
ondemand.notes -- {}

-- Control a specific service within the snap.
ondemand:start()
ondemand:stop()
ondemand:restart()
```

### Set health status

```lua
local snap = require("snap")

snap.health.waiting("waiting for oidc provider to be configured")
```

> Currently there is no support for setting codes. Codes must match the
> regular expression `[a-z](-?[a-z0-9])+`, but Lua patterns do not support
> optional capture groups. Linting the input for codes would require the addition
> of a regular expression module that has a larger memory footprint than the
> Lua programming language itself.

### Retrieve metadata about the snap

```lua
local snap = require("snap")

-- Query `meta/snap.yaml`
local meta = snap.metadata.snap
meta.name -- "ondemand")
meta.base -- "core22"
meta.architectures[1] -- "amd64"
meta["system-usernames"]["snap_daemon"] -- "shared"
```

## License

The `snaphelpers` module is free software, distributed under the GNU Lesser Public License, v3.0. See the [LICENSE](./LICENSE) file for more information.
