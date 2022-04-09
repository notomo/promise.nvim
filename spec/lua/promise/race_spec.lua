local helper = require("promise.test.helper")
local Promise = helper.require("promise")

describe("Promise.race()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("resolves if any promise is resolved", function()
    local got
    local on_finished = helper.on_finished()
    Promise.race({
      Promise.new(function(resolve)
        vim.defer_fn(function()
          resolve(1)
        end, 100)
      end),
      Promise.new(function(resolve)
        vim.defer_fn(function()
          resolve(2)
        end, 50)
      end),
      Promise.new(function(resolve)
        vim.defer_fn(function()
          resolve(3)
        end, 100)
      end),
    }):next(function(v)
      got = v
      on_finished()
    end)
    on_finished:wait()

    assert.is_same(2, got)
  end)

  it("rejects if any promise is rejected", function()
    local want = "error"
    local got
    local on_finished = helper.on_finished()
    Promise.all({
      Promise.new(function(_, reject)
        vim.defer_fn(function()
          reject(1)
        end, 100)
      end),
      Promise.new(function(_, reject)
        vim.defer_fn(function()
          reject(want)
        end, 50)
      end),
      Promise.new(function(_, reject)
        vim.defer_fn(function()
          reject(3)
        end, 100)
      end),
    }):catch(function(err)
      got = err
      on_finished()
    end)
    on_finished:wait()

    assert.equal(want, got)
  end)
end)
