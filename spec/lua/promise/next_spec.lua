local helper = require("promise.test.helper")
local Promise = helper.require("promise")

describe("promise:next()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can chain with non-promise", function()
    local want = "ok"
    local got
    local on_finished = helper.on_finished()
    Promise.new(function(resolve)
      resolve(want)
    end)
      :next(function(v)
        return v
      end)
      :next(function(v)
        got = v
        on_finished()
      end)
    on_finished:wait()

    assert.equal(want, got)
  end)

  it("schedules function to be invoked by event loop", function()
    local promise = Promise.new(function(resolve)
      resolve()
    end)

    local got = {}
    local on_finished1 = helper.on_finished()
    local on_finished2 = helper.on_finished()
    promise
      :next(function()
        table.insert(got, 1)
      end)
      :next(function()
        table.insert(got, 3)
        on_finished1()
      end)
    promise
      :next(function()
        table.insert(got, 2)
      end)
      :next(function()
        table.insert(got, 4)
        on_finished2()
      end)
    on_finished1:wait()
    on_finished2:wait()

    assert.is_same({ 1, 2, 3, 4 }, got)
  end)

  it("skips catch()", function()
    local want = "ok"
    local got
    local called = false
    local on_finished = helper.on_finished()
    Promise.new(function(resolve)
      resolve(want)
    end)
      :catch(function()
        called = true
      end)
      :next(function(v)
        got = v
        on_finished()
      end)
    on_finished:wait()

    assert.is_false(called)
    assert.equal(want, got)
  end)

  it("can chain with promise", function()
    local want = "ok"
    local got
    local on_finished = helper.on_finished()
    Promise.new(function(resolve)
      resolve(want)
    end)
      :next(function(v)
        return Promise.new(function(resolve)
          resolve(v)
        end)
      end)
      :next(function(v)
        got = v
        on_finished()
      end)
    on_finished:wait()

    assert.equal(want, got)
  end)

  it("can chain to promises", function()
    local want = "ok"

    local promise = Promise.new(function(resolve)
      resolve(want)
    end)

    local on_finished1 = helper.on_finished()
    local on_finished2 = helper.on_finished()
    local got1, got2
    promise:next(function(v)
      got1 = v
      on_finished1()
    end)
    promise:next(function(v)
      got2 = v
      on_finished2()
    end)
    on_finished1:wait()
    on_finished2:wait()

    assert.equal(want, got1)
    assert.equal(want, got2)
  end)

  it("can chain with timered promise", function()
    local want = "ok"
    local got
    local on_finished = helper.on_finished()
    Promise.new(function(resolve)
      vim.defer_fn(function()
        resolve(want)
      end, 25)
    end)
      :next(function(v)
        return Promise.new(function(resolve)
          vim.defer_fn(function()
            local want2 = v .. "2"
            resolve(want2)
          end, 25)
        end)
      end)
      :next(function(v)
        got = v
        on_finished()
      end)
    on_finished:wait()

    assert.equal(want .. "2", got)
  end)

  it("can chain with multiple values", function()
    local got
    local on_finished = helper.on_finished()
    Promise.new(function(resolve)
      vim.defer_fn(function()
        resolve(1, 2, 3)
      end, 25)
    end)
      :next(function(...)
        return ...
      end)
      :next(function(...)
        return Promise.resolve(...)
      end)
      :next(function(...)
        got = { ... }
        on_finished()
      end)
    on_finished:wait()

    assert.is_same({ 1, 2, 3 }, got)
  end)
end)
