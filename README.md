# promise.nvim

This implements `Promise` to use with neovim lua.
Mainly used by embedding `lua/promise/init.lua` in plugins.

## Example

```lua
local Promise = require("promise")

Promise.resolve("ok")
  :next(function(value)
    assert(true)
    return "next", value
  end)
  :next(function(...)
    assert(#{ ... } == 2)
  end)
  :catch(function(...)
    assert(false)
    return ...
  end)
  :finally(function()
    assert(true)
  end)

Promise.reject("error")
  :next(function()
    assert(false)
  end)
  :catch(function(err)
    assert(true)
    return "catch", err
  end)

local do_async = function(i)
  return Promise.new(function(resolve, reject)
    vim.defer_fn(function()
      if i % 2 == 1 then
        resolve("ok" .. i)
      else
        reject("error")
      end
    end, i * 10)
  end)
end

local do_async2 = function(i)
  local promise, resolve, reject = Promise.with_resolvers()
  vim.defer_fn(function()
    if i % 2 == 1 then
      resolve("ok" .. i)
    else
      reject("error")
    end
  end, i * 10)
  return promise
end

Promise.all({ do_async(1), do_async(3), do_async(5) }):next(function(value)
  assert(vim.deep_equal(value, { "ok1", "ok3", "ok5" }))
end)

Promise.race({ do_async(1), do_async(3), do_async(5) }):next(function(value)
  assert(value == "ok1")
end)

Promise.any({ do_async(1), do_async(2) }):next(function(value)
  assert(value == "ok1")
end)

Promise.all_settled({ do_async(1), do_async2(2) }):next(function(values)
  assert(values[1].value == "ok1")
  assert(values[1].status == "fulfilled")
  assert(values[2].reason == "error")
  assert(values[2].status == "rejected")
end)
```