{sin, cos, atan2, sqrt, abs, PI} = Math
util = require './utilities'
{
   isNumber 
   fuzzyEqual
   hypot
} = util

{defineProperty} = Object

NumberPair = require './NumberPair'

class Polar extends NumberPair
   constructor: (rho, theta) -> 
      unless this instanceof Polar
         return new Polar(rho, theta)
      super [rho, theta]

      # define own properties (enables 'for own key, val of point')
      defineProperty @, 'rho', 
         enumerable: yes
         get: -> @[0]
         set: (val) -> @[0] = val

      defineProperty @, 'theta', 
         enumerable: yes
         get: -> @[1]
         set: (val) -> @[1] = val

   defProp = util.defProp.bind(@)

   defProp 
      'real, x': 
         get: (-> @rho * cos(@theta))
         set: (new_real) -> 
            {@rho, @theta} = @asPoint().x_(new_real).asPolar()

      'imag, y': 
         get: (-> @rho * sin(@theta))
         set: (new_imag) -> 
            {@rho, @theta} = @asPoint().y_(new_imag).asPolar()

      magnitude: 
         get: -> @rho

      'angle, phase': 
         get: -> @theta

   asPolar: -> this
   asPoint: -> 
      Point = require './Point2d'
      new Point(@x, @y) 

   Complex = require './Complex'
   asComplex: -> 
      new Complex(@real, @imag)

   asString: (opts) -> 
      if opts?.degrees
         @copy().theta_(@Polar.reddeg(@theta)).asString()
      else
         super

   rho_: (val) -> @rho = val; this
   theta_: (val) -> @theta = val; this
   x_: (val) -> @x = val; this
   y_: (val) -> @y = val; this

   scale: (scale) -> new @constructor(@rho * scale, @theta)

   rotate: (angle) -> # in radians
      new @constructor(@rho, @theta + angle)

   neg: -> 
      new @constructor(@rho, @theta + PI)

   plus: (aNumber) -> @asComplex().plus(aNumber)
   add: @::plus
   minus: (aNumber) -> @asComplex().minus(aNumber)
   div: (aNumber) -> @asComplex().div(aNumber)
   times: (aNumber) -> @asComplex().times(aNumber)

   @degrad: (me) -> me * 0.017453292519943295 # Math.PI/180
   @raddeg: (me) -> me * 57.29577951308232 # 180/Math.PI
   @new: (rho, theta) ->
      switch
         when rho instanceof Polar   then rho
         when rho.asPolar?   then rho.asPolar()
         when isNumber( rho[0], rho[1] )       then new Polar rho[0], rho[1]
         when isNumber( rho.rho, rho.theta )   then new Polar rho.rho, rho.theta
         when isNumber( rho, theta )           then new Polar rho, theta
         else
            throw "Polar.new requires numeric rho and theta; got #{rho} and #{theta}"
            null


module.exports = Polar
if require.main is module
   p1 =  Polar( 1, 0 )
   console.log  p1.plus(1)

