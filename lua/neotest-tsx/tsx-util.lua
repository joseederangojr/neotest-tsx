local util = require("neotest-tsx.util")

local M = {}

function M.is_callable(obj)
  return type(obj) == "function" or (type(obj) == "table" and obj.__call)
end

-- Returns tsx binary from `node_modules` if that binary exists and `tsx` otherwise.
---@param path string
---@return string
function M.getTsxCommand(path)
  local gitAncestor = util.find_git_ancestor(path)

  local function findBinary(p)
    local rootPath = util.find_node_modules_ancestor(p)
    local tsxBinary = util.path.join(rootPath, "node_modules", ".bin", "tsx")

    if util.path.exists(tsxBinary) then
      return tsxBinary
    end

    -- If no binary found and the current directory isn't the parent
    -- git ancestor, let's traverse up the tree again
    if rootPath ~= gitAncestor then
      return findBinary(util.path.dirname(rootPath))
    end
  end

  local foundBinary = findBinary(path)

  if foundBinary then
    return foundBinary
  end

  return "tsx"
end

-- Returns tsx config file path if it exists (though tsx may not have config files like jest).
---@param path string
---@return string|nil
function M.getTsxConfig(path)
  -- Tsx doesn't typically have config files like jest, but if needed, can add logic here
  return nil
end

-- Returns neotest test id from tsx test result (assuming similar to jest).
-- @param testFile string
-- @param assertionResult table
-- @return string
function M.get_test_full_id_from_test_result(testFile, assertionResult)
  local keyid = testFile
  local name = assertionResult.title

  for _, value in ipairs(assertionResult.ancestorTitles) do
    keyid = keyid .. "::" .. value
  end

  keyid = keyid .. "::" .. name

  return keyid
end

return M