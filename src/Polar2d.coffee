{sin, cos, atan2, sqrt, abs, PI} = Math
Point = require './Point2d'

util = require './utilities'
{
   isNumber 
   fuzzyEqual
   hypot
} = util

{defineProperty} = Object

class Polar2d
   constructor: (rho, theta) -> 
      unless this instanceof Polar2d
         return new Polar2d(rho, theta)
      @rho = rho
      @theta = theta

   defProp = (obj) =>
      for key, opts of obj
         defineProperty @::, key, opts

   defProp 
      0:
         get: (-> @rho), 
         set: ((new_rho) -> @rho = new_rho)

      1:
         get: (-> @theta), 
         set: ((new_theta) -> @theta = new_theta)

      real: 
         get: (-> @rho * cos(@theta)), 
         set: ((new_real) -> {@rho, @theta} = @asPoint.x_(new_real).asPolar)

      x: 
         get: (-> @rho * cos(@theta)), 
         set: ((new_real) -> {@rho, @theta} = @asPoint.x_(new_real).asPolar)

      imag: 
         get: (-> @rho * sin(@theta)), 
         set: ((new_imag) -> {@rho, @theta} = @asPoint.y_(new_imag).asPolar)

      y: 
         get: (-> @rho * sin(@theta)), 
         set: ((new_imag) -> {@rho, @theta} = @asPoint.y_(new_imag).asPolar)

   get = (obj) =>
      for key, fn of obj
         Object.defineProperty @::, key, get: fn

   get magnitude: -> @rho

   get angle: -> @theta
   get phase: -> @theta

   get asArray: -> [@rho, @theta]
   get asString: -> "#{@rho}, #{@theta}"
   get asPolar: -> this
   get asPoint: -> new Point(@real, @imag) 
   get type: -> util.getName(@constructor)

   toString: -> @asString

   inspect: -> "#{@type}( #{@asString} )"

   rho_: (val) -> @rho = val; this
   theta_: (val) -> @theta = val; this

   scale: (scale) -> new Polar2d(@rho * scale, @theta)

   rotate: (angle) -> # in radians
   	new Polar2d(@rho, @theta + angle)

   isEq: (that, precision) -> 
      aPoint = Point.new(that).asPolar
      return no unless aPoint.rho? and aPoint.theta?
      if precision?
         fuzzyEqual(aPoint.rho, @rho, precision) and 
         fuzzyEqual(aPoint.theta, @theta, precision)
      else
         (aPoint.rho is @rho) and (aPoint.theta is @theta)

   @degrad: (me) -> me * 0.017453292519943295 # Math.PI/180
   @raddeg: (me) -> me * 57.29577951308232 # 180/Math.PI

module.exports = Polar2d
if require.main is module
   p = Polar2d(1, 0)
   console.log p.asPoint
   p.x += 1
   console.log p, p.asPoint

