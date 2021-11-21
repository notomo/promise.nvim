local PackedValue = {}
PackedValue.__index = PackedValue

function PackedValue.new(...)
  local values = vim.F.pack_len(...)
  local tbl = {_values = values}
  return setmetatable(tbl, PackedValue)
end

function PackedValue.pcall(self, f)
  local ok_and_value = function(ok, ...)
    return ok, PackedValue.new(...)
  end
  return ok_and_value(pcall(f, self:unpack()))
end

function PackedValue.unpack(self)
  return vim.F.unpack_len(self._values)
end

function PackedValue.first(self)
  local first = self:unpack()
  return first
end

return PackedValue
