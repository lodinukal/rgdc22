------------------------------------------------------------------------
-- Signal.lua
-- @version v1.0.0
-- @author Centau_ri
------------------------------------------------------------------------

--[[
      This signal module is designed to mimic RBXScriptSignals.

      Details:
            Tables passed will be passed by reference, not deep copied.

            Event handling is not deferred like RBXScriptSignals.

            Signal and Connection objects do not have a `Destroy` method as they can be GCed once they are out of scope.

      	Disconnecting a handler will not instantly remove it from the connections table,
            instead it will cleared without being ran the next time the signal is fired.

            Connection instances do not have a `.Connected` property like RBXScriptConnections, instead use `:IsActive()` to check if a connection has not been disconnected.
]]

local _t = require(script.Parent.Types)

type Signal = _t.Signal; local Signal = {} do
      type array<T> = {T}
      type EventHandler = (...any) -> nil

      -- using arrays to save memory
      local NEXT = 1
      local CALLBACK = 2

      -- connection object doubles as linked list
      type Connection = _t.Connection; local ConnectionClass = {} do

            ConnectionClass.__index = ConnectionClass
            ConnectionClass.__metatable = "Locked"
            ConnectionClass.__tostring = function() return "Connection" end

            function ConnectionClass:IsActive(): boolean
                  return self[CALLBACK] and true or false
            end

            --  removal handled in Signal::Fire
            function ConnectionClass:Disconnect()
                  self[CALLBACK] = nil
            end
      end

      -- coroutine for running callbacks
      local freerunner: (thread | nil)

      -- callback takes ownership of coroutine and returns when complete
      local function runcallback(callback: EventHandler, ...: any)
            local runner: thread = freerunner
            freerunner = nil
            callback(...)
            freerunner = runner
      end

      -- looped runner
      local function newrunner(...: any)
            runcallback(...)
            repeat until runcallback( coroutine.yield() )
      end

      local SignalClass = {}
      SignalClass.__index = SignalClass
      SignalClass.__metatable = "Locked"
      SignalClass.__tostring = function() return "Signal" end

      function Signal.new(): Signal
            return setmetatable({}, SignalClass) :: Signal
      end

      -- connection objects appended onto head of list
      function SignalClass:Connect(callback: EventHandler): Connection
            if type(callback) ~= "function" then
                  error(string.format("Invalid argument #1 to \"Signal::Connect\" (function expected, got %s)", type(callback)), 2)
            end

            local connection: Connection = setmetatable(
                  {self[NEXT], callback},
                  ConnectionClass
            ) :: Connection

            self[NEXT] = connection
            return connection
      end

      --[[
      function SignalClass:ConnectParallel();
      ]]

      function SignalClass:Wait(): ...any
            local current = coroutine.running()
            local c: Connection; c = self:Connect(function(...: any)
                  c:Disconnect()
                  local success: boolean, error_msg: string? = coroutine.resume(current, ...)
                  if success == false then error(error_msg, 0) end
            end)
            return coroutine.yield()
      end

      --[[
            iterate through linked list
            disconnected connections are checked and removed here
            (basically free removal at the cost of an extra branch)
      ]]
      function SignalClass:Fire(...: any)
            local prev_connection: Connection = self::Connection
            local connection: Connection = self[NEXT]
            while connection ~= nil do
                  local callback = connection[CALLBACK]
                  if callback == nil then
                        prev_connection[NEXT] = connection[NEXT]
                  else
                        -- if the previous callback runner hasn't been returned then create a new one
                        if freerunner == nil then freerunner = coroutine.create(newrunner) end
                        local success: boolean, error_msg: string? = coroutine.resume(freerunner, callback, ...)
                        if success == false then error(error_msg, 2) end
                  end
                  prev_connection = connection
                  connection = connection[NEXT]
            end
      end

      function SignalClass:DisconnectAll()
            self[NEXT] = nil
      end

      table.freeze(Signal)
end

return Signal