{sin, cos, atan2, sqrt, abs, max, min, PI} = Math

util = require './utilities'

{
   isNumber 
   fuzzyEqual
   hypot
   roundTo
} = util

NumberPair = require './NumberPair'

class Point2d extends NumberPair
   constructor: (x, y) -> 
      unless this instanceof Point2d
         return new Point2d(x, y)
      super [x, y]

      # define own properties (enables 'for own key, val of point')
      Object.defineProperty @, 'x', 
         enumerable: yes
         get: -> @[0]
         set: (val) -> @[0] = val

      Object.defineProperty @, 'y', 
         enumerable: yes
         get: -> @[1]
         set: (val) -> @[1] = val


   defProp = util.defProp.bind(@)

   defProp 
      'rho, magnitude':
         get: (-> hypot( @x, @y ))
         set: (new_rho) -> 
            {@x, @y} = @asPolar().rho_(new_rho).asPoint()

      'theta, angle':
         get: (-> atan2( @y, @x ))
         set: ((new_theta) -> {@x, @y} = @asPolar().theta_(new_theta).asPoint())

   # get = util.get.bind(@)

   abs: -> new Point2d( abs(@x), abs(@y) )

   neg: -> new Point2d( -@x, -@y )

   transpose: -> new Point2d(@y, @x) 

   asPoint: -> this
   asPolar: -> 
      Polar = require './Polar'
      new Polar(@rho, @theta)
   asComplex: -> 
      Complex = require './Complex'
      new Complex(@x, @y)

   x_: (val) -> @x = val; this
   y_: (val) -> @y = val; this
   rho_: (val) -> @rho = val; this
   theta_: (val) -> @theta = val; this

   plus: (aPoint) ->
      aPoint = @constructor.new arguments...
      new @constructor( @x + aPoint.x, @y + aPoint.y )
   translate: @::plus
   add: @::plus

   minus: (aPoint) ->
      aPoint = @constructor.new arguments...
      new @constructor( @x - aPoint.x, @y - aPoint.y )

   div: (aPoint) ->
      aPoint = @constructor.new arguments...
      new @constructor( @x / aPoint.x, @y / aPoint.y )
    
   scale: (aPoint) ->
      aPoint = @constructor.new arguments...
      new @constructor( @x * aPoint.x, @y * aPoint.y )
   times: @::scale

   scaleAbout: (factor, aPoint...) -> # in radians
      aPoint = @constructor.new aPoint...
      @minus(aPoint).scale(factor).plus(aPoint)

   rotate: (angle) -> # in radians
      sinr = sin(angle)
      cosr = cos(angle)
      new @constructor( (@x * cosr) - (@y * sinr), (@y * cosr) + (@x * sinr) )

   rotateAbout: (angle, aPoint...) -> # in radians
      aPoint = @constructor.new aPoint...
      @minus(aPoint).rotate(angle).plus(aPoint)

   dist: (aPoint) ->
      [dx, dy] = @minus arguments...
      hypot(dx,dy)
  
   angleTo: (aPoint) ->
      aPoint = @constructor.new arguments...
      aPoint.minus(@).angle

   angleToDeg: -> @angleTo(arguments...)*180/PI

   @new: (x, y) ->
      switch
         when x instanceof Point2d   then x
         when x.asPoint?   then x.asPoint()
         when isNumber( x[0], x[1] ) then new Point2d x[0], x[1]
         when isNumber( x.x, x.y )   then new Point2d x.x, x.y
         when isNumber( x, y )       then new Point2d x, y
         when isNumber( x )          then new Point2d x, x
         else
            throw "Point2d.new requires numeric x and y; got #{x} and #{y}"
            null

Object.defineProperty Point2d, 'origin', get: -> new Point2d( 0, 0 )

module.exports = Point2d

if require.main is module
   p = Point2d(0,1)
   console.log p.rho 
   console.log p.magnitude 
   console.log p.theta 
   console.log p.angle 
   console.log p.rho_(2).y 
   console.log p.theta_(0).isFuzzyEq([2,0], 1e-10) 
