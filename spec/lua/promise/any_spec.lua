local helper = require("promise.test.helper")
local Promise = helper.require("promise")
local assert = require("assertlib").typed(assert)

describe("Promise.any()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("resolves if any promise is resolved", function()
    local got
    local on_finished = helper.on_finished()
    Promise.any({
      1,
      Promise.new(function(resolve)
        vim.defer_fn(function()
          resolve(2)
        end, 25)
      end),
      Promise.resolve(3),
    }):next(function(v)
      got = v
      on_finished()
    end)
    on_finished:wait()

    assert.same(1, got)
  end)

  it("rejects if empty", function()
    local got
    local on_finished = helper.on_finished()
    Promise.any({}):catch(function(errs)
      got = errs
      on_finished()
    end)
    on_finished:wait()
    assert.same({}, got)
  end)

  it("rejects if all promise is rejected", function()
    local got
    local on_finished = helper.on_finished()
    Promise.any({
      Promise.reject(1),
      Promise.new(function(_, reject)
        vim.defer_fn(function()
          reject(2)
        end, 25)
      end),
      Promise.reject(3),
    }):catch(function(errr)
      got = errr
      on_finished()
    end)
    on_finished:wait()

    assert.same({ 1, 2, 3 }, got)
  end)
end)
