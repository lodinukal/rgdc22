--------------------------------------------------------------------------------
-- RDL.lua
-- @version 1.1.0
--------------------------------------------------------------------------------

--[[
      Roblox Development Library
      Provides commonly used classes, datastructures, libraries and functions to assist in development.
      This library and all its components are licensed under the MIT license.
]]

local _t = require(script.Types)

export type Complex = _t.Complex
export type List = _t.List
export type ListNode = _t.ListNode
export type Signal = _t.Signal
export type Connection = _t.Connection

local rdl = {}

rdl.class = require(script.class)
rdl.Complex = require(script.Complex)
rdl.List = require(script.List)
rdl.setFrequency = require(script.setFrequency)
rdl.shared = require(script.shared)
rdl.Signal = require(script.Signal)

return rdl
