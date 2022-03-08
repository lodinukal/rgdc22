------------------------------------------------------------------------
-- setFrequency.lua
-- @version v1.0.0
-- @author Centau_ri
------------------------------------------------------------------------

--[[
      Self correcting clock that fires a callback at a set frequency.
      Better alternative to the `while wait() do` pattern since coroutines are not repeatedly ran and yielded.
      Returns a RBXScriptConnection you can disconnect yourself.
]]

local Heartbeat: RBXScriptSignal = game:GetService("RunService").Heartbeat

return function(frequency: number, callback: () -> nil): RBXScriptConnection
      local period: number = 1/frequency
      local elapsed_upval: number = 0

      return Heartbeat:Connect(function(dt: number)
            local elapsed: number = elapsed_upval -- cache upvalue to avoid writing to it twice
            elapsed += dt
            while elapsed >= period do
                  elapsed -= period
                  callback()
            end
            elapsed_upval = elapsed
      end)
end
