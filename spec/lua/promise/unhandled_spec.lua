local helper = require("promise.lib.testlib.helper")
local Promise = helper.require("promise")

after_each(function()
  collectgarbage("collect")
end)

describe("unhandled rejection detector", function()

  before_each(helper.before_each)
  after_each(function()
    helper.after_each()
    collectgarbage("collect")
  end)

  it("does not raise error even if catched by separated declaration", function()
    local on_finished = helper.on_finished()
    do
      local p = Promise.new(function(_, reject)
        reject("should handled")
      end):finally(function()
        on_finished()
      end)
      -- should raise error if the following `catch` is commented out.
      -- but no error occurs if tests are filtered to only this describe.
      p:catch(function()
      end)
    end
    on_finished:wait()
  end)

end)

