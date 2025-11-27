-- Neovim test script for neotest-tsx adapter
-- Run with: nvim -c "source test_adapter.vim"

print("Testing neotest-tsx adapter...")
print("================================")

-- Set up package path to find our modules
package.path = package.path .. ";" .. vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua"

-- Load the adapter
local ok, adapter = pcall(require, "neotest-tsx")
if not ok then
    print("❌ Failed to load adapter:", adapter)
    return
end

print("✓ Adapter loaded successfully")

-- Test 1: Check if adapter has required fields
print("\n1. Testing adapter structure:")
print("   - Name:", adapter.name or "MISSING")
print("   - root function:", type(adapter.root) == "function" and "✓" or "✗")
print("   - filter_dir function:", type(adapter.filter_dir) == "function" and "✓" or "✗")
print("   - is_test_file function:", type(adapter.is_test_file) == "function" and "✓" or "✗")
print("   - discover_positions function:", type(adapter.discover_positions) == "function" and "✓" or "✗")
print("   - build_spec function:", type(adapter.build_spec) == "function" and "✓" or "✗")
print("   - results function:", type(adapter.results) == "function" and "✓" or "✗")

-- Test 2: Test file detection
print("\n2. Testing file detection:")
local test_files = {
    "tests/basic.test.ts",
    "tests/example.spec.ts",
    "src/utils.js",
    "lib/helper.ts",
    "package.json"
}

for _, file in ipairs(test_files) do
    local is_test = adapter.is_test_file(file)
    local status = is_test and "✓ TEST FILE" or "✗ NOT A TEST FILE"
    print(string.format("   - %s: %s", file, status))
end

-- Test 3: Test root detection
print("\n3. Testing root detection:")
local test_paths = {
    vim.fn.getcwd() .. "/tests/basic.test.ts",
    vim.fn.getcwd() .. "/src/utils.ts",
    vim.fn.getcwd() .. "/package.json"
}

for _, path in ipairs(test_paths) do
    local root = adapter.root(path)
    local result = root or "NO ROOT"
    print(string.format("   - %s -> %s", vim.fn.fnamemodify(path, ":t"), result))
end

-- Test 4: Test directory filtering
print("\n4. Testing directory filtering:")
local dirs = {
    "node_modules",
    "src",
    "tests",
    ".git",
    "build"
}

for _, dir in ipairs(dirs) do
    local should_filter = adapter.filter_dir(dir)
    local status = should_filter and "FILTERED" or "ALLOWED"
    print(string.format("   - %s: %s", dir, status))
end

-- Test 5: Test position discovery (if treesitter is available)
print("\n5. Testing position discovery:")
local test_file = vim.fn.getcwd() .. "/tests/basic.test.ts"
if vim.fn.filereadable(test_file) == 1 then
    local success, positions = pcall(adapter.discover_positions, test_file)
    if success and positions then
        print("   ✓ Position discovery successful")
        -- Count positions
        local count = 0
        local function count_positions(tree)
            count = count + 1
            for _, child in ipairs(tree:children() or {}) do
                count_positions(child)
            end
        end
        count_positions(positions)
        print(string.format("   - Found %d test positions", count))
    else
        print("   ✗ Position discovery failed:", positions)
    end
else
    print("   ⚠ Test file not found, skipping position discovery test")
end

print("\n================================")
print("Adapter test completed!")