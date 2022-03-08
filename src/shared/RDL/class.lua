--------------------------------------------------------------------------------
-- class.lua v1.0.0
-- @Centau_ri
--------------------------------------------------------------------------------

--[[
      Provides a fast, intuitive way to create user-defined classes.
      Just as fast as traditional oop, and *much* faster when using derived classes.
      See class.md for more info.
]]

type table = {[any]: any}
type array<T> = {[number]: T}

type Proxy = {}
type Object = {[string]: any}
type Method = (Object, ...any) -> ...any

type RawConstructor = (Object, ...any) -> nil
type DirectConstructor = (...any) -> Object

type Constructor = (...any) -> Object

--[[
      constants variables used by compile function
]]

local LOCK_METATABLE = "Locked"

local overloads: array<string> = { -- operations users are allowed to define overloads for
      "__call",
      "__concat",
      "__unm",
      "__add",
      "__sub",
      "__mul",
      "__div",
      "__mod",
      "__pow",
      "__tostring",
      "__eq",
      "__lt",
      "__le",
      "__mode",
      "__gc",
      "__len"
}

local reserved_names: array<string> = { -- users cannot define any member beginning with "__" either
      "new"
}

local non_inheritables: array<string> = { -- special members that will not be inherited
      "__class",
      "__init",
}

local Enum = {
      MemberType = { -- determines member type
            Constructor = 0x00,
            Method      = 0x01,
            Metamethod  = 0x02,
      },

      ProcessResult = { -- determines how constructor type
            Error       = 0x00,
            Yield       = 0x01,
            Direct      = 0x02,
            Success     = 0x03
      },

      MemberOrigin = {  -- determines how to handle redefinitions
            New         = 0x00,
            Property    = 0x01,
            Inherited   = 0x02
      }
}

-- evaluates constructor type
local function processConstructor(raw: RawConstructor): (number, Object | string | nil)
      -- fills function parameters with dummy values
      local function fillParameters(): ...boolean
            return unpack(table.create(debug.info(raw, 'a'), true))
      end

      local success: boolean, variant: any;

      success, variant = pcall(function() -- check if constructor errors or yields
            return -setmetatable({}, {__unm = function() raw({}, fillParameters()) end})
      end)
      if success == false then
            local yieldErrors = {
                  "thread is not yieldable",
                  "attempt to yield across metamethod/C-call boundary"
            }

            if table.find(yieldErrors, variant) then
                  return Enum.ProcessResult.Yield
            else
                  return Enum.ProcessResult.Error, variant
            end
      end

      success, variant = pcall(raw, fillParameters()) -- constructs dumy object and checks for direct initialization
      if success == true then
            if variant ~= nil then
                  return Enum.ProcessResult.Direct, variant
            end
      end

      local obj: Object = {};
      success = pcall(raw, obj, fillParameters()) -- constructs dummy object (standard constructor)
      if success == true then
            return Enum.ProcessResult.Success, obj
      end

      error("Error processing") -- this should never run
end

local function errorf(stack: number, error_msg: string, ...: any)
      error(string.format(error_msg, ...), stack+1)
end

-- prevents nil indexes
local strict = function(self, key: string) errorf(2, "%s is not a valid member of class %s", key, tostring(self)) end

-- internal store of classes for inheritence, gced after current resumption cycle
local __classes = setmetatable({}, {__mode = 'k'})

--[[
      this function:
            1. creates class tables
            2. performs checks on data
            3. wraps constructor functions
            5. assigns members and metamethods
            6. handles inheritance
            7. returns reference to class table
]]

-- initializes class table and class metatable
local function compileClass(classCreationData: table, parentClassTables: array<table>?): table
      -- unexposed instance metatable
      local class_metatable: table = { --UPVALUE
            __metatable = LOCK_METATABLE,
            __index = {}
      }

      -- metatable of class table
      local class_table_metatable: table = {
            __metatable = LOCK_METATABLE,
            __index = strict,

            -- set later
            __newindex = nil
      }

      -- class table, exposes static members to users
      local class_table = setmetatable({}, class_table_metatable)

      -- allow access to class table from class instance through "__class" key
      class_metatable.__index.__class = class_table

      -- temporary register of created members to check for duplicate definitions, gced after current resumption cycle
      local tmp: {[string]: number} = {}

      -- sets default constructor
      rawset(class_table, "new", function() return setmetatable({}, class_metatable) end)

      -- member processor
      local function processMembers(data: table)
            -- sets up standard constructors
            local function setupConstructor(raw_constr: RawConstructor): Constructor -- investigate if implicit calling of parent constructor is possible
                  return function(...): Object
                        local obj: Object = setmetatable({}, class_metatable)
                        raw_constr(obj, ...)
                        return obj
                  end
            end

            -- sets up direct initialization constructors
            local function setupDirectConstructor(raw_constr: DirectConstructor): Constructor
                  local arity: number, variadic: boolean = debug.info(raw_constr, 'a')
                  local switch: array<Constructor> = {
                        [0] = function()           return setmetatable(raw_constr(),           class_metatable) end;
                        [1] = function(a)          return setmetatable(raw_constr(a),          class_metatable) end;
                        [2] = function(a, b)       return setmetatable(raw_constr(a, b),       class_metatable) end;
                        [3] = function(a, b, c)    return setmetatable(raw_constr(a, b, c),    class_metatable) end;
                        [4] = function(a, b, c, d) return setmetatable(raw_constr(a, b, c, d), class_metatable) end;
                  }

                  return (variadic == false and arity <= #switch)
                        and switch[arity]
                        or function(...) return setmetatable(raw_constr(...), class_metatable) end
            end

            -- process members
            for memberRawName: string, memberRawFunction: (...any) -> ...any in next, data do
                  do -- error checking I
                        if type(memberRawFunction) ~= "function" then errorf(4, "Expected function when defining class member \"%s\", got %s", memberRawName, type(memberRawFunction)) end
                  end

                  -- error function
                  local function errorm(error_msg: string, ...: any)
                        local sourceName: string = debug.info(memberRawFunction, 's')
                        local sourceLine: number = debug.info(memberRawFunction, 'l')
                        errorf(-1, sourceName..":"..sourceLine..":\n"..error_msg, ...)
                  end

                  do -- error checking II
                        if type(memberRawName) ~= "string" then errorm("Invalid member name (string expected, got %s)", type(memberRawName)) end
                        if string.match(memberRawName, "^[%a_][%w_]*$") == nil then errorm("Invalid member name \"%s\" (invalid characters)", memberRawName) end --^[a-zA-Z_$][a-zA-Z_$0-9]*$
                  end

                  -- assign member type and define member name
                  local memberType: number, memberName: string do
                        if string.sub(memberRawName, 1, 6) == "__init" then
                              memberType = Enum.MemberType.Constructor
                              local nameSpecifier: string = string.sub(memberRawName, 7, -1)

                              if nameSpecifier ~= "" then
                                    if string.sub(nameSpecifier, 1, 2) ~= "__" then errorm("Expected identifier \"__<NAME>\" when parsing constructor name, got %s", nameSpecifier) end
                                    memberName = string.sub(nameSpecifier, 3, -1)
                              else
                                    memberName = "new"
                              end
                        elseif table.find(overloads, memberRawName) then
                              memberType = Enum.MemberType.Metamethod
                              memberName = memberRawName
                        else
                              memberType = Enum.MemberType.Method
                              memberName = memberRawName
                        end
                  end

                  do -- errorm checking III
                        if string.sub(memberRawName, 1, 2) == "__" and memberType == Enum.MemberType.Method then errorm("Member names beginning with \"__\" are reserved. (\"__init\" or metamethod expected, got \"%s\")", memberRawName) end
                        if tonumber(string.sub(memberRawName, 1, 1)) then errorm("Member name \"%s\" cannot begin with a number", memberName) end
                        if debug.info(memberRawFunction, 'a') == 0 and memberType ~= Enum.MemberType.Constructor then errorm("Member function \"%s\" does not have \"self\" defined", memberName) end
                        if table.find(reserved_names, memberName) and (memberType ~= Enum.MemberType.Constructor and memberName == "new") then errorm("\"%s\" is a reserved member name", memberName) end
                        if tmp[memberName] and tmp[memberName] ~= Enum.MemberOrigin.Inherited then errorm("Duplicate member name \"%s\" (A member function or property already exists with this name)", memberName) end
                        tmp[memberName] = Enum.MemberOrigin.New
                  end

                  ({ -- assign members
                        [Enum.MemberType.Constructor] = function()
                              local constructor: Constructor;

                              local result: number, variant: (Object | string | nil) = processConstructor(memberRawFunction::RawConstructor); ({
                                    [Enum.ProcessResult.Error] = function()
                                          errorm("Exception occured while processing constructor %s\n(%s)", memberName, variant)
                                    end;

                                    [Enum.ProcessResult.Yield] = function()
                                          errorm("Cannot yield in constructor %s", memberName)
                                    end;

                                    [Enum.ProcessResult.Direct] = function()
                                          if type(variant) ~= "table" then errorm("Invalid direct constructor return type (table expected, got %s)", type(variant)) end
                                          constructor = setupDirectConstructor(memberRawFunction::DirectConstructor)
                                    end;

                                    [Enum.ProcessResult.Success] = function()
                                          if debug.info(memberRawFunction, 'a') == 0 then errorm("Constructor \"%s\" does not have \"self\" defined", memberName) end
                                          constructor = setupConstructor(memberRawFunction::RawConstructor)
                                    end;
                              })[result]()

                              for property: string in next, variant::Object do
                                    if tmp[property] == Enum.MemberOrigin.New then errorm("Duplicate member name \"%s\" (A member function already exist with this name)", property); end
                                    tmp[property] = Enum.MemberOrigin.Property
                              end

                              rawset(class_table, memberName, constructor)
                              rawset(class_table, memberRawName, memberRawFunction)
                        end;

                        [Enum.MemberType.Method] = function()
                              class_metatable.__index[memberName] = memberRawFunction
                        end;

                        [Enum.MemberType.Metamethod] = function()
                              class_metatable[memberName] = memberRawFunction
                        end;
                  })[memberType]()
            end
      end

      -- inheritance
      for _, parentClassTable: table in next, parentClassTables or {}::{} do
            local parentClassMetatable: table = __classes[parentClassTable]
            if parentClassMetatable == nil then errorf(4, "Expected to inherit from user-defined class, got %s", type(parentClassTable)) end

            for memberName: string, memberFunction: Method in next, parentClassMetatable.__index do -- inherit methods
                  if tmp[memberName] == nil and table.find(non_inheritables, memberName) == nil then
                        class_metatable.__index[memberName] = memberFunction
                        tmp[memberName] = Enum.MemberOrigin.Inherited
                  end
            end

            for metamethodName: string, metamethodRawFunction: Method in next, parentClassMetatable do -- inherit metamethods
                  if tmp[metamethodName] == nil and table.find(overloads, metamethodName) then
                        class_metatable[metamethodName] = metamethodRawFunction
                        tmp[metamethodName] = Enum.MemberOrigin.Inherited
                  end
            end
      end

      -- lock table
      do
            -- allow creation of members after class initialization
            function class_table_metatable:__newindex(idx: string, nv: any)
                  processMembers({[idx] = nv})
            end

            -- call class table to freeze it
            function class_table_metatable:__call()
                  class_table_metatable.__metatable = nil
                  table.freeze(class_table)
                  class_table_metatable.__metatable = LOCK_METATABLE
                  class_table_metatable.__newindex = nil
                  class_table_metatable.__call = nil
                  return self
            end
      end

      __classes[class_table] = class_metatable

      -- post-initialization
      processMembers(classCreationData)
      return class_table
end

--[[
      expose method for use by other scripts
]]

return function(...: table)
      local args: array<table> = { ... }

      if type(args[1]) ~= "table" then errorf(2, "Invalid argument #1 to \"class\" (table expected, got %s)", type(args[1])) end

      -- if first argument is an existing class (specifying parent classes)
      if __classes[args[1]] then
            local ran = false
            local source = debug.info(2, 's')..":"..debug.info(2, 'l')..":\n"
            task.defer(function() if ran == false then errorf(2, source.."Class was never defined, did you forget to include \"{}\"?") end; end)
            return function(memberData: table): table
                  ran = true
                  return compileClass(memberData, args)
            end

      -- if first argument is member data (creating a new class)
      else
            return compileClass(args[1])
      end
end