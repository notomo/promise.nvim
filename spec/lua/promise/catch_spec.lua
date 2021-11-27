local helper = require("promise.lib.testlib.helper")
local Promise = helper.require("promise")

describe("promise:catch()", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can chain with non-promise", function()
    local want = "error"
    local got
    local on_finished = helper.on_finished()
    Promise.new(function(_, reject)
      reject(want)
    end):catch(function(err)
      got = err
      on_finished()
    end)
    on_finished:wait()

    assert.equal(want, got)
  end)

  it("skips next()", function()
    local want = "error"
    local got
    local called = false
    local on_finished = helper.on_finished()
    Promise.new(function(_, reject)
      reject(want)
    end):next(function()
      called = true
    end):catch(function(err)
      got = err
      on_finished()
    end)
    on_finished:wait()

    assert.is_false(called)
    assert.equal(want, got)
  end)

  it("can chain with promise", function()
    local want = "error"
    local got
    local on_finished = helper.on_finished()
    Promise.new(function(_, reject)
      reject(want)
    end):catch(function(v)
      return Promise.new(function(_, reject)
        reject(v)
      end)
    end):catch(function(v)
      got = v
      on_finished()
    end)
    on_finished:wait()

    assert.equal(want, got)
  end)

  it("can chain to promises", function()
    local want = "error"

    local promise = Promise.new(function(_, reject)
      reject(want)
    end)

    local on_finished1 = helper.on_finished()
    local on_finished2 = helper.on_finished()
    local got1, got2
    promise:catch(function(v)
      got1 = v
      on_finished1()
    end)
    promise:catch(function(v)
      got2 = v
      on_finished2()
    end)
    on_finished1:wait()
    on_finished2:wait()

    assert.equal(want, got1)
    assert.equal(want, got2)
  end)

  it("catches error() in next()", function()
    local want = "error"
    local got
    local on_finished = helper.on_finished()
    Promise.new(function(resolve)
      resolve(want)
    end):next(function(v)
      error(v, 0) -- 0 not to add error position to message
    end):catch(function(err)
      got = err
      on_finished()
    end)
    on_finished:wait()

    assert.equal(want, got)
  end)

  it("can chain with timered promise", function()
    local want = "error"
    local got
    local on_finished = helper.on_finished()
    Promise.new(function(resolve)
      resolve("ok")
    end):next(function()
      return Promise.new(function(_, reject)
        vim.defer_fn(function()
          reject(want)
        end, 25)
      end)
    end):catch(function(v)
      got = v
      on_finished()
    end)
    on_finished:wait()

    assert.equal(want, got)
  end)

  it("can chain with multiple values", function()
    local got
    local on_finished = helper.on_finished()
    Promise.new(function(_, reject)
      vim.defer_fn(function()
        reject(1, 2, 3)
      end, 25)
    end):catch(function(...)
      return Promise.reject(...)
    end):catch(function(...)
      got = {...}
      on_finished()
    end)
    on_finished:wait()

    assert.is_same({1, 2, 3}, got)
  end)

end)
