set rtp+=.
set rtp+=.testdeps/plenary.nvim
set rtp+=.testdeps/nvim-treesitter
set rtp+=.testdeps/neotest
set rtp+=.testdeps/nvim-nio

lua <<EOF
-- Add testdeps to package.path
local cwd = vim.fn.getcwd()
package.path = package.path .. ";" .. cwd .. "/.testdeps/plenary.nvim/lua/?.lua"
package.path = package.path .. ";" .. cwd .. "/.testdeps/nvim-nio/lua/?.lua"
package.path = package.path .. ";" .. cwd .. "/.testdeps/neotest/lua/?.lua"
package.path = package.path .. ";" .. cwd .. "/lua/?.lua"

require'nvim-treesitter.configs'.setup {
  -- Make sure we have javascript and typescript treesitter parsers installed so tests can run
  ensure_installed = { "javascript", "typescript" },
  sync_install = true
}
EOF

runtime! plugin/plenary.vim