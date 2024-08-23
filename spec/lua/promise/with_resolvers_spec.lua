local helper = require("promise.test.helper")
local Promise = helper.require("promise")

describe("Promise.with_resolvers()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("returns promise with resolve", function()
    local got
    local on_finished = helper.on_finished()
    local promise, resolve = Promise.with_resolvers()

    vim.schedule(function()
      resolve("ok")
    end)
    promise:next(function(v)
      got = v
      on_finished()
    end)
    on_finished:wait()

    assert.is_same("ok", got)
  end)

  it("returns promise with reject", function()
    local got
    local on_finished = helper.on_finished()
    local promise, _, reject = Promise.with_resolvers()

    vim.schedule(function()
      reject("error")
    end)
    promise:catch(function(err)
      got = err
      on_finished()
    end)
    on_finished:wait()

    assert.is_same("error", got)
  end)
end)
