local helper = require("promise.lib.testlib.helper")
local Promise = helper.require("promise")

describe("promise:finally()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("continues from next()", function()
    local called = false
    local on_finished = helper.on_finished()
    Promise.new(function(resolve)
      resolve("ok")
    end)
      :next(function(v)
        return v
      end)
      :finally(function()
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
    end)
      :next(function(v)
        return v
      end)
      :finally(function()
        -- noop
      end)
      :next(function(v)
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
    end)
      :catch(function(err)
        error(err)
      end)
      :finally(function()
        called = true
      end)
      :catch(function()
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
    end)
      :catch(function(err)
        error(err, 0)
      end)
      :finally(function()
        -- noop
      end)
      :catch(function(err)
        got = err
        on_finished()
      end)
    on_finished:wait()

    assert.is_same(want, got)
  end)
end)
