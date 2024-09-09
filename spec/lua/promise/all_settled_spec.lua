local helper = require("promise.test.helper")
local Promise = helper.require("promise")
local assert = require("assertlib").typed(assert)

describe("Promise.all_settled()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("resolves on all promises with status", function()
    local got
    local on_finished = helper.on_finished()
    Promise.all_settled({
      1,
      Promise.new(function(_, reject)
        vim.defer_fn(function()
          reject(2)
        end, 25)
      end),
      Promise.resolve(3),
    }):next(function(v)
      got = v
      on_finished()
    end)
    on_finished:wait()

    assert.same({
      { status = "fulfilled", value = 1 },
      { status = "rejected", reason = 2 },
      { status = "fulfilled", value = 3 },
    }, got)
  end)

  it("resolves even if empty", function()
    local got
    local on_finished = helper.on_finished()
    Promise.all_settled({}):next(function(v)
      got = v
      on_finished()
    end)
    on_finished:wait()
    assert.same({}, got)
  end)
end)
