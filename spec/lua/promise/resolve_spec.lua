local helper = require("promise.test.helper")
local Promise = helper.require("promise")

describe("Promise.resolve()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("if the argument is a non-promise value, returns a new promise", function()
    local want = "ok"
    local got
    local p = Promise.resolve(want):next(function(v)
      got = v
    end)

    helper.wait(p)
    assert.equal(want, got)
  end)

  it("if the arguments are non-promise values, returns a new promise", function()
    local want1, want2 = "ok1", "ok2"
    local got
    local p = Promise.resolve(want1, want2):next(function(...)
      got = { ... }
    end)

    helper.wait(p)
    assert.is_same({ want1, want2 }, got)
  end)

  it("if the argument is a promise, returns the promise", function()
    local p1 = Promise.new(function(resolve)
      resolve("ok")
    end)
    local p2 = Promise.resolve(p1)

    assert.equal(p1, p2)
  end)
end)
