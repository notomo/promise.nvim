local helper = require("promise.test.helper")
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

  it("is resolved even if reject() is called after resolve()", function()
    local rejected = false
    local p = Promise.new(function(resolve, reject)
      resolve()
      reject()
    end):catch(function()
      rejected = true
    end)

    helper.wait(p)
    assert.is_false(rejected)
  end)

  it("is rejected even if resolve() is called after reject()", function()
    local resolved = false
    local p = Promise.new(function(resolve, reject)
      reject()
      resolve()
    end)
      :next(function()
        resolved = true
      end)
      :catch(function() end)

    helper.wait(p)
    assert.is_false(resolved)
  end)
end)
