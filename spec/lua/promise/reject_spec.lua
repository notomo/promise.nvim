local helper = require("promise.test.helper")
local Promise = helper.require("promise")

describe("Promise.reject()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("if the argument is a non-promise value, returns a new promise", function()
    local want = "error"
    local got
    local p = Promise.reject(want):catch(function(v)
      got = v
    end)

    helper.wait(p)
    assert.equal(want, got)
  end)

  it("if the arguments are non-promise values, returns a new promise", function()
    local want1, want2 = "error1", "error2"
    local got
    local p = Promise.reject(want1, want2):catch(function(...)
      got = { ... }
    end)

    helper.wait(p)
    assert.is_same({ want1, want2 }, got)
  end)

  it("if the argument is a promise, returns the promise", function()
    local p1 = Promise.new(function(_, reject)
      reject("error")
    end)
    local p2 = Promise.reject(p1)

    assert.equal(p1, p2)

    p1:catch(function() end)
    p2:catch(function() end)
  end)
end)
