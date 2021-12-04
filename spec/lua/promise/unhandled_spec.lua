local helper = require("promise.lib.testlib.helper")
local Promise = helper.require("promise")

describe("unhandled rejection detector", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("does not raise error even if catched by separated declaration", function()
    local on_finished = helper.on_finished()
    do
      local p = Promise.new(function(_, reject)
        reject("should handled1")
      end):finally(function()
        on_finished()
      end)
      -- should raise error if the following `catch` is commented out.
      -- but no error occurs if tests are filtered to only this `it`.
      p:catch(function()
      end)
    end
    on_finished:wait()
  end)

  it("does not raise error if catched by chained declaration", function()
    local on_finished = helper.on_finished()
    do
      Promise.new(function(_, reject)
        reject("should handled2")
      end):finally(function()
        on_finished()
      end):catch(function()
      end)
    end
    on_finished:wait()
  end)

end)
