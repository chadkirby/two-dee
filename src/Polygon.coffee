{sin, cos, atan2, sqrt, abs, max, min, PI} = Math

util = require './utilities'

{
   isNumber 
   fuzzyEqual
   hypot
   roundTo
   square
   flatten
} = util

Point = require './Point2d'
Line = require './Line'
Rect = require './Rect'

class Polygon
   constructor: (points...) ->
      unless this instanceof Polygon
         return new Polygon(points...)
      @points = []
      @_envelope = Rect.infinite()
      for point in points
         @push point

   push: (point) -> @setAt @points.length, point

   setAt: (index, point) ->
      pt = Point.new(point)
      @_envelope.left = pt.x if pt.x < @_envelope.left
      @_envelope.top = pt.y if pt.y < @_envelope.top
      @_envelope.right = pt.x if pt.x > @_envelope.right
      @_envelope.bottom = pt.y if pt.y > @_envelope.bottom
      @points[index] = pt

   addOffsetPoint: (offset) -> 
      pt = @last().translate arguments...
      @push pt

   defProp = util.defProp.bind(@)
   
   last: -> @points[@length-1]

   defProp 
      right: 
         get: -> @_envelope.right
      left: 
         get: -> @_envelope.left
      top: 
         get: -> @_envelope.top
      bottom: 
         get: -> @_envelope.bottom

      length:
         get: -> @points.length

      'width, w':
         get: -> @_envelope.width
      'height, h':
         get: -> @_envelope.height
      x: 
         get: -> @_envelope.left
      y: 
         get: -> @_envelope.top

      origin:
         get: -> @_envelope.origin
      corner:
         get: -> @_envelope.corner
      extent:
         get: -> @_envelope.extent
      
      leftTop:
         get: -> @_envelope.leftTop
      rightTop:
         get: -> @_envelope.rightTop
      leftBottom:
         get: -> @_envelope.leftBottom
      rightBottom:
         get: -> @_envelope.rightBottom
      type:
         get: -> util.getName(@constructor)

   # width_: (h) -> @right = @_envelope.left + h; this
   # height_: (v) -> @_envelope.bottom = @_envelope.top + v; this

   # copy: -> new @constructor( @_envelope.left, @right, @_envelope.top, @_envelope.bottom )

   lineSegments: ->
      segments = []
      for p1 in @points
         if p0?
            segments.push( new Line(p0, p1) )
         p0 = p1
      # util.doPairs @points, (pt0, pt1) -> new Line pt0, pt1 
      segments.push( new Line( p0, @points[0] ))
      segments

   closestPointOnShape: (aPoint) ->
      aPoint = Point.new arguments...
      segment = @closestShapeSegment(aPoint)
      segment.closestPointOnSegment(aPoint)

   closestShapeSegment: (aPoint) ->
      aPoint = Point.new arguments...
      minDist = Infinity
      closestSegment = null
      for segment in @lineSegments()
         pt = segment.closestPointOnSegment(aPoint)
         dist = pt.distTo(aPoint)
         if dist < minDist
            minDist = dist
            closestSegment = segment
      closestSegment

   envelope: (offset = 0) -> @_envelope.insetBy(-offset, -offset)    

   controlPts: (ptsPerSegment = 2) ->
      out = []
      denom = ptsPerSegment + 1
      for line in @lineSegments()
         for ii in [1..ptsPerSegment]
            out.push line.at(ii/denom)
      out

   inspect: -> "#{@type}( #{@asString(fixed: 4)} )"

   asString: (opts) -> 
      out = for point in @points
         point.asString(opts)
      "[#{out.join('], [')}]"

   svgString: (opts = {}) ->
      svg = for pt, ii in @points
         pt.asString(opts)
      """
      M#{svg.join '  L'} z
      """
   map: (fn) ->
      for pt, ii in @points
         fn(pt, ii)

   moveBy: (h, v) -> 
      pts = @map (pt) -> pt.translate h, v
      new @constructor(pts...)
   translate: @::moveBy
  
   moveTo: (aPoint) -> 
      aPoint = Point.new arguments...
      delta = aPoint.minus @points[0]
      @moveBy delta

   scaleAbout: (scale, origin) ->
      scale = Point.new scale
      pts = @map (pt) -> pt.scaleAbout scale, origin
      new @constructor pts... 
      
   rotateAbout: (rotate, origin) ->
      pts = @map (pt) -> pt.rotateAbout rotate, origin
      new @constructor pts... 
      
   scale: (h, v) ->
      scale = Point.new arguments...
      origin = @points[0]
      pts = @map (pt) -> pt.scaleAbout scale, origin
      new @constructor pts... 
   resizeBy: @::scale

   #### http://paulbourke.net/geometry/polygonmesh/
   area: ->
      area = 0
      pts = @points
      nPts = pts.length
      j = nPts - 1
      p1 = undefined
      p2 = undefined
      i = 0

      while i < nPts
         p1 = pts[i]
         p2 = pts[j]
         area += p1.x * p2.y
         area -= p1.y * p2.x
         j = i++
      area /= 2
      area

   centroid: -> 
      pts = @points
      nPts = pts.length
      x = 0
      y = 0
      f = undefined
      j = nPts - 1
      p1 = undefined
      p2 = undefined
      i = 0

      while i < nPts
         p1 = pts[i]
         p2 = pts[j]
         f = p1.x * p2.y - p2.x * p1.y
         x += (p1.x + p2.x) * f
         y += (p1.y + p2.y) * f
         j = i++
      f = @area() * 6
      Point.new( x / f, y / f )

   # resizeBy: (h, v) -> new Polygon(@_envelope.left, @_envelope.top, @right + h, @_envelope.bottom + v)
  
   # resizeTo: (h, v) -> new Polygon(@_envelope.left, @_envelope.top, @_envelope.left + h, @_envelope.top + v)
  
   # insetBy: (h, v) -> new Polygon(@_envelope.left + h, @_envelope.top + v, @right - h, @_envelope.bottom - v)
  
   # insetAll: (a, b, c, d) -> new Polygon(@_envelope.left + a, @_envelope.top + b, @right - c, @_envelope.bottom - d)
  
   # contains: (aPoint) -> 
   #    {x, y} = aPoint
   #    (@_envelope.left <= x <= @right) and
   #    (@_envelope.bottom <= y <= @_envelope.top)
   
   # intersects: (aPolygon) -> 
   #    aPolygon = Polygon.new aPolygon
   #    return no if aPolygon.right < @_envelope.left
   #    return no if aPolygon.bottom < @_envelope.top
   #    return no if aPolygon.left > @right
   #    return no if aPolygon.top > @_envelope.bottom
   #    yes
   


   # @new: (arg0, arg1, arg2, arg3) ->
   #    switch
   #       when arg0 instanceof Polygon   then arg0
   #       when Point.quacksLikeAPoint(arg0) 
   #          p0 = Point.new(arg0)
   #          if Point.quacksLikeAPoint(arg1)
   #             p1 = Point.new(arg1)
   #             new Polygon(
   #                min( p0.x, p1.x)
   #                min( p0.y, p1.y)
   #                max( p0.x, p1.x)
   #                max( p0.y, p1.y)
   #             )
   #          else if isNumber(arg1, arg2)
   #             wid = arg1
   #             hgt = arg2
   #             new Polygon(
   #                p0.x
   #                p0.y
   #                p0.x + wid
   #                p0.y + hgt
   #             )
   #       else
   #          new Polygon arguments...

module.exports = Polygon

if require.main is module
   r = Polygon [61.427898, 72.746506]
   s = """
      l13.11,-25.45 
      l2.74,-46.09  
      l-21.956,-0.46 
      l-24.6,3.8  
      l3.94,62.26 
   """
   for line in s.split '\n'
      [match, pt0, pt1] = /l(.+),(.+)/.exec line
      r.addOffsetPoint +pt0, +pt1

   console.log r.scale(0.5).translate(5, 5).controlPts(1)
   console.log r.moveBy 10, 10
   console.log r.controlPts(1)
   console.log r.svgString(fixed: 4)
   console.log r.envelope
   console.log r.area(), r.centroid()
   console.log r.rotateAbout( Math.PI, r.centroid())


