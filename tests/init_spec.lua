-- Set up package path to find our modules
local cwd = vim.fn.getcwd()
package.path = package.path .. ";" .. cwd .. "/.testdeps/plenary.nvim/lua/?.lua"
package.path = package.path .. ";" .. cwd .. "/.testdeps/nvim-nio/lua/?.lua"
package.path = package.path .. ";" .. cwd .. "/.testdeps/neotest/lua/?.lua"
package.path = package.path .. ";" .. cwd .. "/lua/?.lua"

local async = require("nio").tests
local Tree = require("neotest.types").Tree

---@type neotest.Adapter
local plugin = require("neotest-tsx")({
  command = "tsx",
})
require("neotest-tsx-assertions")
A = function(...)
  print(vim.inspect(...))
end

describe("adapter enabled", function()
  async.it("tsx simple repo", function()
    assert.Not.Nil(plugin.root("./tests"))
  end)

  async.it("enable adapter with package.json", function()
    assert.Not.Nil(plugin.root("."))
  end)
end)

describe("is_test_file", function()
  local original_dir
  before_each(function()
    original_dir = vim.api.nvim_eval("getcwd()")
  end)

  after_each(function()
    vim.api.nvim_set_current_dir(original_dir)
  end)

  async.it("matches tsx test files", function()
    vim.api.nvim_set_current_dir("./tests")
    assert.is.truthy(plugin.is_test_file("./basic.test.ts"))
  end)

  async.it("does not match plain ts files", function()
    assert.is.falsy(plugin.is_test_file("./index.ts"))
  end)

  async.it("does not match file name ending with test", function()
    assert.is.falsy(plugin.is_test_file("./setupTsx.ts"))
  end)
end)

-- describe("discover_positions", function()
--   ... commented out for now
-- end)

describe("build_spec", function()
  local raw_tempname
  before_each(function()
    raw_tempname = require("neotest.async").fn.tempname
    require("neotest.async").fn.tempname = function()
      return "/tmp/foo"
    end
  end)
  after_each(function()
    require("neotest.async").fn.tempname = raw_tempname
  end)

  describe("test name pattern", function()
    async.it("file level", function()
      local positions = plugin.discover_positions("./tests/basic.test.ts"):to_list()
      local tree = Tree.from_list(positions, function(pos)
        return pos.id
      end)
      local spec = plugin.build_spec({ tree = tree })
    assert(spec.command[4] == "--test-name-pattern=.*")
    end)
    async.it("namespace level", function()
      local positions = plugin.discover_positions("./tests/basic.test.ts"):to_list()
      local tree = Tree.from_list(positions, function(pos)
        return pos.id
      end)
      local spec = plugin.build_spec({ tree = tree:children()[1] })
      assert.contains(spec.command, "--test-name-pattern=^Basic Math Tests")
    end)
    async.it("test level", function()
      local positions = plugin.discover_positions("./tests/basic.test.ts"):to_list()
      local tree = Tree.from_list(positions, function(pos)
        return pos.id
      end)
      local spec = plugin.build_spec({ tree = tree:children()[1]:children()[1] })
      assert.contains(spec.command, "--test-name-pattern=^Basic Math Tests should add two numbers correctly$")
    end)
  end)

  async.it("builds command for file test", function()
    local positions = plugin.discover_positions("./tests/basic.test.ts"):to_list()
    local tree = Tree.from_list(positions, function(pos)
      return pos.id
    end)
    local spec = plugin.build_spec({ tree = tree })
    assert.is.truthy(spec)
    -- Note: tsx command uses --test-reporter and --test-reporter-destination
    -- The command should include tsx, reporter options, and the file
    assert.contains(spec.command, "tsx")
    assert.contains(spec.command, "--test-reporter=")
    assert.contains(spec.command, "--test-reporter-destination=/tmp/foo")
    assert.contains(spec.command, "--test-name-pattern=.*")
    assert.is.truthy(spec.context.file)
    assert.is.truthy(spec.context.results_path)
  end)

  async.it("builds command passed tsx command ", function()
    local positions = plugin.discover_positions("./tests/basic.test.ts"):to_list()
    local tree = Tree.from_list(positions, function(pos)
      return pos.id
    end)
    local spec = plugin.build_spec({ command = "tsx --watch", tree = tree })

    assert.is.truthy(spec)
    assert.contains(spec.command, "tsx")
    assert.contains(spec.command, "--watch")
    assert.contains(spec.command, "--test-reporter=")
    assert.contains(spec.command, "--test-reporter-destination=/tmp/foo")
    assert.contains(spec.command, "--test-name-pattern=.*")
    assert.is.truthy(spec.context.file)
    assert.is.truthy(spec.context.results_path)
  end)

  async.it("builds command for namespace", function()
    local positions = plugin.discover_positions("./tests/basic.test.ts"):to_list()

    local tree = Tree.from_list(positions, function(pos)
      return pos.id
    end)

    local spec = plugin.build_spec({ tree = tree:children()[1] })

    assert.is.truthy(spec)
    assert.contains(spec.command, "tsx")
    assert.contains(spec.command, "--test-reporter=")
    assert.contains(spec.command, "--test-reporter-destination=/tmp/foo")
    assert.contains(spec.command, "--test-name-pattern=^Basic Math Tests")
    assert.is.truthy(spec.context.file)
    assert.is.truthy(spec.context.results_path)
  end)
end)