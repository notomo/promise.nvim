local helper = require("promise.lib.testlib.helper")
local Promise = helper.require("promise")

describe("Promise.new()", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("is fullfilled if resolve() is called", function()
    local want = "ok"
    local got
    local p = Promise.new(function(resolve)
      resolve(want)
    end):next(function(v)
      got = v
    end)

    helper.wait(p)
    assert.equal(want, got)
  end)

  it("is rejected if reject() is called", function()
    local want = "error"
    local got
    local p = Promise.new(function(_, reject)
      reject(want)
    end):catch(function(v)
      got = v
    end)

    helper.wait(p)
    assert.equal(want, got)
  end)

end)
