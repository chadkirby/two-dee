{sin, cos, atan2, sqrt, abs, max, min, PI} = Math

util = require './utilities'

{
   isNumber 
   fuzzyEqual
   hypot
   roundTo
   square
} = util

Point = require './Point2d'

class LineSegment
   constructor: (p0, p1) ->
      unless this instanceof LineSegment
         return new LineSegment(p0, p1)
      @points = [
         Point.new p0
         Point.new p1
      ]

   defProp = util.defProp.bind(@)
   
   defProp 
      'p0, start':
         get: -> @points[0]
         set: (val) ->
            @points[0] = Point.new arguments...
      'p1, end':
         get: -> @points[1]
         set: (val) ->
            @points[1] = Point.new arguments...
      x0:
         get: -> @start.x
      x1:
         get: -> @end.x
      y0:
         get: -> @start.y
      y1:
         get: -> @end.y
      length:
         get: -> @p0.dist @p1
         set: (val) ->
            @end = @end.scaleAbout(val, @start)
      dx:
         get: -> @end.x - @start.x
      dy:
         get: -> @end.y - @start.y
      'slope, m':
         get: -> @dy/@dx            
      yIntercept: 
         get: -> @yAt 0
      type:
         get: -> util.getName(@constructor)

   copy: -> new @constructor( @start, @end )
   inspect: -> "#{@type}( #{@asString()} )"

   asString: (opts) -> 
      "[#{@start.asString(opts)}], [#{@end.asString(opts)}]"

   mapPoints: (fn) ->
      @points = for point, i in @points
         fn(point, i)
      this

   scaleAbout: (factor, origin = Point.origin) ->
      @mapPoints (point, i) ->
         point.scaleAbout( factor, origin )

   rotateAbout: (factor, origin = Point.origin) ->
      @mapPoints (point, i) ->
         point.rotateAbout( factor, origin )

   translate: (aPoint) ->
      aPoint = Point.new arguments...
      @copy().mapPoints (point, i) -> 
         console.log point, aPoint, point.translate(aPoint)
         point.translate aPoint



   yAt: (x) -> @m * (x - @x0) + @y0 # returns y value for a given x

   pointAt: (tt) -> ## tt is timing scalar betw 0..1
      Point(
         @x0 + tt * @dx,
         @y0 + tt * @dy,
      )

   svgString: ->
      "M #{@start.asString()} L #{@end.asString()}"

   envelope: (offset = 3) ->
      if @dx is 0 or @dy is 0 # horz or vert line
         Rect = require './Rect'
         rr = Rect.new @start, @end
         rr.envelope(offset)

   _closestTT: (aPoint, min, max) ->
      AP = aPoint.minus @start
      ab2 = @dx*@dx + @dy*@dy
      ap_ab = AP.x*@dx + AP.y*@dy
      tt = ap_ab / ab2
      if min? and tt < min
         min
      else if max? and tt > max
         max
      else
         tt

   distToPoint: (aPoint) -> # Return minimum distance to aPoint
      aPoint = Point.new arguments...
      tt = @_closestTT(aPoint, 0, 1)
      @pointAt(tt).distTo(aPoint)

   closestPointOnSegment: (aPoint) ->
      aPoint = Point.new arguments...
      tt = @_closestTT(aPoint, 0, 1)
      @pointAt(tt)

   closestPointOnLine: (aPoint) ->
      aPoint = Point.new arguments...
      tt = @_closestTT(aPoint)
      @pointAt(tt)

module.exports = LineSegment

if require.main is module
   l = LineSegment( [0,0], [5, 5])
   console.log l
   console.log l.svgString()
   console.log l.distToPoint 2, 3
   console.log l.yAt 4
   console.log l.pointAt 0.4
   console.log l.closestPointOnSegment -1, 0
   console.log l.closestPointOnLine -1, 0
   l = LineSegment( [0,0], [5, 0])
   console.log l.envelope()

