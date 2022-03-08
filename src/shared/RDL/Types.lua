------------------------------------------------------------------------
-- Signal.lua
-- @version v1.0.0
------------------------------------------------------------------------

-- private types
type fn = (...any) -> ...any
type table = {any}
type array<T> = {T}

-- Complex
export type Complex = {
      X: number,
      Y: number,
      Magnitude: (Complex) -> number,
      AbsSquare: (Complex) -> number,
      Conjugate: (Complex) -> Complex,
      ToPolar: (Complex) -> (number, number),
      Orbit: (Complex, c: Complex, maxIter: number, escapeOrbit: number?) -> number
      -- no way to define operator overloads?
}

-- List
export type List = {
      [number]: ListNode,
      Push: (List, v: any) -> nil,
      Pop: (List) -> any,
      Front: (List) -> any,
      Back: (List) -> any,
      Size: (List) -> number,
      ToArray: (List) -> (array<any>, number)
}

export type ListNode = {any | ListNode?}

-- Signal
export type Connection = {
      [number]: Connection | fn,
      IsActive: (Connection) -> boolean,
      Disconnect: (Connection) -> nil
}

export type Signal = {
      Connect: (Signal, callback: fn) -> Connection,
      Wait: (Signal) -> ...any,
      Fire: (Signal, ...any) -> nil,
      DisconnectAll: (Signal) -> nil
}

return nil