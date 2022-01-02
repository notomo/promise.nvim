local helper = require("promise.lib.testlib.helper")
local Promise = helper.require("promise")

describe("Promise.all()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("resolves on all promises", function()
    local got
    local on_finished = helper.on_finished()
    Promise.all({
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

    assert.is_same({ 1, 2, 3 }, got)
  end)

  it("resolves even if empty", function()
    local got
    local on_finished = helper.on_finished()
    Promise.all({}):next(function(v)
      got = v
      on_finished()
    end)
    on_finished:wait()
    assert.is_same({}, got)
  end)

  it("rejects if any promise is rejected", function()
    local want = "error"
    local got
    local on_finished = helper.on_finished()
    Promise.all({
      1,
      Promise.new(function(_, reject)
        vim.defer_fn(function()
          reject(want)
        end, 25)
      end),
      Promise.resolve(3),
    }):catch(function(err)
      got = err
      on_finished()
    end)
    on_finished:wait()

    assert.equal(want, got)
  end)
end)
