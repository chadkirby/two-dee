{sin, cos, atan2, sqrt, abs, max, min, PI, round, ceil} = Math

util = require './utilities'

{
   isNumber 
   fuzzyEqual
   hypot
   roundTo
   square
} = util

Point = require './Point2d'

interleave = (lists...) ->
   arr = []
   ii = 0
   while (list = lists.shift())
      continue unless list.length > 0
      arr.push(list.shift())
      lists.push(list)
   arr

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
         set: ->
            @points[0] = Point.new arguments...
      p1:
         get: -> @points[1]
         set: ->
            @points[1] = Point.new arguments...
      end:
         get: -> @points[@points.length-1]
         set: ->
            @points[@points.length-1] = Point.new arguments...
      x0:
         get: -> @start.x
      x1:
         get: -> @end.x
      y0:
         get: -> @start.y
      y1:
         get: -> @end.y
      length:
         get: -> @p0.distTo @p1
         set: (val) ->
            @end = @end.scaleAbout(val/@length, @start)
      dx:
         get: -> @end.x - @start.x
      dy:
         get: -> @end.y - @start.y
      center:
         get: -> Point.new( @x0 + @dx/2, @y0 + @dy/2)
      'slope, m':
         get: -> @dy/@dx            
      yIntercept: 
         get: -> @yAt 0
      type:
         get: -> util.getName(@constructor)
      normal: 
         get: -> new @constructor(Point.new( -@dy, @dx ), Point.new( @dy, -@dx ))

      A:
         get: -> @p1.y - @p0.y
      B:
         get: -> @p0.x - @p1.x
      C:
         get: -> @A*@p0.x + @B*@p0.y

   copy: -> new @constructor( @start, @end )
   inspect: -> "#{@type}( #{@asString()} )"

   asString: (opts) -> 
      "[#{@start.asString(opts)}], [#{@end.asString(opts)}]"

   Rect = require './Rect'
   asRect: -> Rect.new @start, @end

   mapPoints: (fn) ->
      @points = for point, i in @points
         fn(point, i)
      this

   transpose: -> new @constructor @p1, @p0

   splitN: (numberOfPieces) ->
      nn = 1/Math.max(1, numberOfPieces)
      tts = (tt for tt in [nn..1] by nn)
      if numberOfPieces % 1 is 0
         # want even segments
         tts.push round(tts.pop())
      @split(tts...)

   split: (tts...) ->
      tts = util.flatten(tts)
      tts.push(1) unless (1 in tts)
      for tt in tts when tt > 0
         p0 = p1 ? @p0
         p1 = @pointAt(tt)
         new @constructor p0, p1
   
   asPath: (maxPointSpacing) ->
      segmentCount = @length/maxPointSpacing
      nn = 1/Math.max(1, segmentCount)
      tts = (tt for tt in [0..1-nn] by nn)
      tts.push 1 
      for tt in tts 
         @pointAt(tt)

   scaleAbout: (factor, origin = Point.origin) ->
      @copy().mapPoints (point, i) ->
         point.scaleAbout( factor, origin )

   extendBy: (additionalLength) ->
      tt = (@length + additionalLength)/@length
      new @constructor(@p0, @pointAt(tt))

   rotateAbout: (factor, origin = Point.origin) ->
      @mapPoints (point, i) ->
         point.rotateAbout( factor, origin )

   rotate: (factor) ->
      copy = @copy()
      copy.p1 = copy.p1.rotateAbout factor, copy.p0
      copy

   translate: (aPoint) ->
      aPoint = Point.new arguments...
      @copy().mapPoints (point, i) -> 
         point.translate aPoint
   moveBy: @::translate

   moveTo: (aPoint) ->
      aPoint = Point.new arguments...
      delta = aPoint.minus @start
      new @constructor( aPoint, @end.translate( delta ) )

   splitFromCenter: ->
      [l0, l1] = @split(0.5)
      [l0.transpose(), l1]

   centerAt: (aPoint) ->
      aPoint = Point.new arguments...
      [l0, l1] = for segment, i in @splitFromCenter()
         segment.moveTo( aPoint )
      new @constructor l0.p1, l1.p1

   yAt: (x) -> @m * (x - @x0) + @y0 # returns y value for a given x

   pointAt: (tt) -> ## tt is timing scalar betw 0..1
      Point(
         @x0 + tt * @dx,
         @y0 + tt * @dy,
      )

   at: @::pointAt

   svgString: ->
      "M #{@start.asString()} L #{@end.asString()}"

   envelope: (offset = 3, n = 1) ->
      # Rect = require './Rect'
      if n <= 1 
         @asRect().envelope(offset)
      else
         offsetTT = -offset/@length
         offsetLine = new LineSegment @pointAt(offsetTT), @pointAt(1 - offsetTT)
         segments = offsetLine.splitN(n)
         for segment in segments
            segment.asRect()

   alternatingPathFromPoint: (aPoint, stepSize=1) ->
      aPoint = Point.new aPoint
      start = @_closestTT(aPoint)
      stepTT = stepSize/@length
      tt = start
      loPath = while (tt >= stepTT)
         tt -= stepTT
         @pointAt(tt)

      tt = start
      max = 1 - stepTT
      hiPath = while (tt <= max)
         tt += stepTT
         @pointAt(tt)

      interleave(loPath, hiPath)



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

   normalAt: (tt) -> 
      origin = @pointAt(tt)
      @normal.centerAt(origin)

   normalsAt: (tt) -> @normalAt(tt).splitFromCenter()

   intersection: (aLine) ->
      # http://community.topcoder.com/tc?module=Static&d1=tutorials&d2=geometry2
      det = @A*aLine.B - aLine.A*@B
      return null if det is 0 # lines are parallel

      pt = Point.new (aLine.B*@C - @B*aLine.C)/det, (@A*aLine.C - aLine.A*@C)/det
      pt




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
   l = LineSegment( [0,0], [15, 15])
   console.log l.split 0.25, 0.5, 0.75
   console.log l.splitN 2.5
   console.log l.normal
   console.log l.centerAt(1, 0)
   console.log l.normalAt(0)
   console.log l.normalsAt(0)
   console.log l.normalsAt(1)
   console.log l.envelope(1, 6)
   console.log l.splitN(6)
   m = LineSegment([15,0], [0,15])
   console.log l.intersection(m)

   l = LineSegment( [0,0], [10, 0])
   console.log l.extendBy(1)




