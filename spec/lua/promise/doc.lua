local util = require("genvdoc.util")
local example_path = "./spec/lua/promise/example.lua"

local wait = dofile(example_path)
vim.wait(1000, function()
  return wait.finished
end, 10, false)

require("genvdoc").generate("promise.nvim", {
  chapters = {
    {
      name = function(group)
        return "Lua module: " .. group
      end,
      group = function(node)
        if node.declaration == nil or node.declaration.type ~= "function" then
          return nil
        end
        return node.declaration.module
      end,
    },
    {
      name = "EXAMPLES",
      body = function()
        local exclude = false
        return util.help_code_block_from_file(example_path, {
          include = function(line)
            exclude = exclude or line:match("finished")
            return not exclude
          end,
          language = "lua",
        })
      end,
    },
  },
})

local gen_readme = function()
  local exmaple = util.read_all(example_path):gsub("local wait.*", "")

  local content = ([[
# promise.nvim

This implements `Promise` to use with neovim lua.
Mainly used by embedding `lua/promise/init.lua` in plugins.

## Example

```lua
%s```]]):format(exmaple)

  util.write("README.md", content)
end
gen_readme()
