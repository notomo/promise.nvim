local helper = require("test.helper")
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

describe("promise:next()", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can chain with non-promise", function()
    local want = "ok"
    local got
    local on_finished = helper.on_finished()
    Promise.new(function(resolve)
      resolve(want)
    end):next(function(v)
      return v
    end):next(function(v)
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
    promise:next(function()
      table.insert(got, 1)
    end):next(function()
      table.insert(got, 3)
      on_finished1()
    end)
    promise:next(function()
      table.insert(got, 2)
    end):next(function()
      table.insert(got, 4)
      on_finished2()
    end)
    on_finished1:wait()
    on_finished2:wait()

    assert.is_same({1, 2, 3, 4}, got)
  end)

  it("skips catch()", function()
    local want = "ok"
    local got
    local called = false
    local on_finished = helper.on_finished()
    Promise.new(function(resolve)
      resolve(want)
    end):catch(function()
      called = true
    end):next(function(v)
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
    end):next(function(v)
      return Promise.new(function(resolve)
        resolve(v)
      end)
    end):next(function(v)
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
    end):next(function(v)
      return Promise.new(function(resolve)
        vim.defer_fn(function()
          local want2 = v .. "2"
          resolve(want2)
        end, 25)
      end)
    end):next(function(v)
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
    end):next(function(...)
      return ...
    end):next(function(...)
      return Promise.resolve(...)
    end):next(function(...)
      got = {...}
      on_finished()
    end)
    on_finished:wait()

    assert.is_same({1, 2, 3}, got)
  end)

end)

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

describe("promise:finally()", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("continues from next()", function()
    local called = false
    local on_finished = helper.on_finished()
    Promise.new(function(resolve)
      resolve("ok")
    end):next(function(v)
      return v
    end):finally(function()
      called = true
      on_finished()
    end)
    on_finished:wait()

    assert.is_true(called)
  end)

  it("passes value to next()", function()
    local want = "ok"
    local got
    local on_finished = helper.on_finished()
    Promise.new(function(resolve)
      resolve(want)
    end):next(function(v)
      return v
    end):finally(function()
      -- noop
    end):next(function(v)
      got = v
      on_finished()
    end)
    on_finished:wait()

    assert.is_same(want, got)
  end)

  it("continues from catch()", function()
    local called = false
    local on_finished = helper.on_finished()
    Promise.new(function(_, reject)
      reject("error")
    end):catch(function(err)
      error(err)
    end):finally(function()
      called = true
    end):catch(function()
      on_finished()
    end)
    on_finished:wait()

    assert.is_true(called)
  end)

  it("passes err to catch()", function()
    local want = "error"
    local got
    local on_finished = helper.on_finished()
    Promise.new(function(_, reject)
      reject(want)
    end):catch(function(err)
      error(err, 0)
    end):finally(function()
      -- noop
    end):catch(function(err)
      got = err
      on_finished()
    end)
    on_finished:wait()

    assert.is_same(want, got)
  end)

end)

describe("all", function()

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

    assert.is_same({1, 2, 3}, got)
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

describe("race", function()

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

-- TODO more specification test
