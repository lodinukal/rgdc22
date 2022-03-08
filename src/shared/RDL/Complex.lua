------------------------------------------------------------------------
-- Complex.lua
-- @version v1.0.0
-- @author Centau_ri
------------------------------------------------------------------------

export type Complex = any; local Complex = {} do
      local ComplexClass = {}
      ComplexClass.__index = ComplexClass
      ComplexClass.__metatable = "Locked"

      -- constructors
      local function new(x: number?, y: number?): Complex
            return setmetatable({
                  X = x or 0,
                  Y = y or 0
            }, ComplexClass)::Complex
      end
      Complex.new = new

      function Complex.fromPolar(pa: number, r: number): Complex
            return new(math.cos(pa)*r, math.sin(pa)*r)
      end

      -- member functions
      local function abs(z: Complex): number
            return (z.X^2 + z.Y^2)^0.5
      end
      ComplexClass.Magnitude = abs

      function ComplexClass.AbsSquare(z: Complex): number
            return z.X^2 + z.Y^2
      end

      function ComplexClass.Conjugate(z: Complex): Complex
            return new(z.X, -z.Y)
      end

      function ComplexClass.ToPolar(z: Complex): (number, number)
            local zr: number, zi: number = z.X, z.Y
            return math.atan2(zi, zr), (zr*zr + zi*zi)^0.5
      end

      function ComplexClass.Orbit(z: Complex, c: Complex, maxIter: number, escapeOrbit: number?): number
            local escapeOrbit2 = (escapeOrbit or 2)^2
            local zr: number, zi: number, cr: number, ci: number = z.X, z.Y, c.X, c.Y
            local zr2: number, zi2: number = zr*zr, zi*zi

            local iter: number = 0
            while zr2 + zi2 <= escapeOrbit2 and iter < maxIter do
                  zi = (zr+zr)*zi + ci
                  zr = zr2 - zi2 + cr
                  zr2 = zr*zr
                  zi2 = zi*zi
                  iter += 1
            end
            return iter
      end

      -- operator overloads
      function ComplexClass.__add(z: Complex, w: Complex): Complex
            return new(z.X + w.X, z.Y + w.Y)
      end

      function ComplexClass.__sub(z: Complex, w: Complex): Complex
            return new(z.X - w.X, z.Y - w.Y)
      end

      function ComplexClass.__unm(z: Complex): Complex
            return new(-z.X, -z.Y)
      end

      function ComplexClass.__mul(z: Complex, w: Complex): Complex
            local zr: number, zi: number, wr: number, wi: number = z.X, z.Y, w.X, w.Y
            return new(zr*wr - zi*wi, zr*wi + zi*wr)
      end

      function ComplexClass.__div(z: Complex, w: Complex): Complex
            local zr: number, zi: number, wr: number, wi: number = z.X, z.Y, w.X, w.Y
            local inv: number = 1/(wr*wr + wi*wi)
            return new((zr*wr + zi*wi)*inv, (zi*wr - zr*wi)*inv)
      end

      function ComplexClass.__pow(z: Complex, w: Complex): Complex -- 0^0 undefined
            local e: Complex = w * new(math.log(abs(z)), math.atan2(z.Y, z.X))::any
            local nr: number = math.exp(e.X)
            local ni: number = e.Y
            return new(nr * math.cos(ni), nr * math.sin(ni))
      end

      function ComplexClass.__eq(z: Complex, w: Complex): boolean
            return z.X == w.X and z.Y == w.Y
      end

      function ComplexClass.__tostring(z: Complex): string
            return '('..z.X.." + "..z.Y..'i'..')'
      end

      table.freeze(Complex)
end

return Complex
