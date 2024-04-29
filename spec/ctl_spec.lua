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

--- Mock object for the result of `io.popen`.
---@class MockPopen
local MockPopen = {}
MockPopen.__index = MockPopen

--- Create a new `MockPopen` object.
---@return MockPopen
function MockPopen:new()
  local mock = {}
  setmetatable(mock, MockPopen)
  return mock
end

--- Mock `read(...)`.
function MockPopen:read(...)
  return "ondemand.ondemand  disabled  inactive  -\n"
end

--- Mock `close()`.
function MockPopen:close() end


describe("`snap.ctl`: test ctl module", function()
  setup(function()
    -- Set mock `SNAP` env var. Required by the `snap.metadata` module.
    posix.setenv("SNAP", "/snap/ondemand/x1")

    -- Export mocked `snap` to global namespace.
    _G.snap = require("snap")

    -- Mock result of `io.popen`.
    stub(io, "popen", function(...)
      return MockPopen:new()
    end)
  end)

  test("`snap.ctl`: test `os.capture` utility", function()
    -- Remove additional newline at the end of command output.
    local result = os.capture("/usr/bin/snapctl services ondemand", false)
    assert.are.equal(result, "ondemand.ondemand  disabled  inactive  -")

    -- Do not remove additional newline at the end of command output.
    local result = os.capture("/usr/bin/snapctl services ondemand", true)
    assert.are.equal(result, "ondemand.ondemand  disabled  inactive  -\n")
  end)
end)
