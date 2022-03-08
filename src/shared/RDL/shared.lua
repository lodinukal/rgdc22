------------------------------------------------------------------------
-- shared.lua
-- @version v1.0.0
-- @author Centau_ri
------------------------------------------------------------------------

--[[
      Returns a function that converts the `shared` global into a wrapper for the ReplicatedStorage service.

      Note: the only behaviour this cannot emulate is setting the parent of an instance to ReplicatedStorage,
      i.e. `part.Parent = shared` will not work.
]]

return function()
      local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

      local metatable = {
            __index = function(_, index: any): any
                  local v = ReplicatedStorage[index]
                  if type(v) ~= "function" then
                        return v
                  else
                        return function(_, ...: any)
                              return ReplicatedStorage[index](ReplicatedStorage, ...)
                        end
                  end
            end;

            __call = function(): ReplicatedStorage
                  return ReplicatedStorage
            end;

            __tostring = function(): string
                  return tostring(ReplicatedStorage)
            end;
      }

      table.freeze(setmetatable(shared, metatable))
      metatable.__metatable = getmetatable(ReplicatedStorage::{any})
end