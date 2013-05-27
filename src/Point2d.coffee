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
            {@x, @y} = @asPolar.rho_(new_rho).asPoint

      'theta, angle':
         get: (-> atan2( @y, @x ))
         set: ((new_theta) -> {@x, @y} = @asPolar.theta_(new_theta).asPoint)

   get = util.get.bind(@)

   get abs: -> new Point2d( abs(@x), abs(@y) )

   get neg: -> new Point2d( -@x, -@y )

   get transpose: -> new Point2d(@y, @x) 

   get asPoint: -> this

   get asPolar: -> 
         Polar = require './Polar2d'
         new Polar(@rho, @theta)

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

   rotate: (angle) -> # in radians
      sinr = sin(angle)
      cosr = cos(angle)
      new @constructor( (@x * cosr) - (@y * sinr), (@y * cosr) + (@x * sinr) )

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
         when isNumber( x.x, x.y )   then new Point2d x.x, x.y
         when isNumber( x[0], x[1] ) then new Point2d x[0], x[1]
         when isNumber( x, y )       then new Point2d x, y
         when isNumber( x )          then new Point2d x, x
         else
            console.warn "Point2d.new requires numeric x and y; got #{x} and #{y}"
            null

Object.defineProperty Point2d, 'origin', get: -> new Point2d( 0, 0 )

module.exports = Point2d

if require.main is module
   p = Point2d(0,1)
   o = Point2d.origin
   console.log p, p.x, p[0], p.y
   for own key, val of p
      console.log key, val

   for val in p
      console.log val
