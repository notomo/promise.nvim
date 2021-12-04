local Promise = require("promise")

Promise.resolve("ok"):next(function(value)
  assert(true)
  return "next", value
end):next(function(...)
  assert(#{...} == 2)
end):catch(function(...)
  assert(false)
  return ...
end):finally(function()
  assert(true)
end)

Promise.reject("error"):next(function()
  assert(false)
end):catch(function(err)
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

Promise.all({do_async(1), do_async(3), do_async(5)}):next(function(value)
  assert(vim.deep_equal(value, {"ok1", "ok3", "ok5"}))
end)

Promise.race({do_async(1), do_async(3), do_async(5)}):next(function(value)
  assert(value == "ok1")
end)

Promise.any({do_async(1), do_async(2)}):next(function(value)
  assert(value == "ok1")
end)
local wait = {finished = false}
do_async(33):next(function()
end):next(function()
end):next(function()
end):next(function()
end):next(function()
  wait.finished = true
end)

return wait
