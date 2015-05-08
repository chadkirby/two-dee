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

class Rect
   constructor: (left=0, top=0, right=0, bottom=0) ->
      unless this instanceof Rect
         return new Rect(left, top, right, bottom)
      @left = left #min(left, right)
      @top = top #min(top, bottom)
      @right = right #max(left, right)
      @bottom = bottom #max(top, bottom)

   defProp = util.defProp.bind(@)
   
   defProp 
      'width, w':
         get: -> @right - @left
         set: (h) -> @right = @left + h
      'height, h':
         get: -> @bottom - @top
         set: (v) -> @bottom = @top + v
      x: 
         get: -> @left
         set: (x) -> 
            w = @w
            @left = x
            @right = x + w
      y: 
         get: -> @top
         set: (y) -> 
            h = @h
            @top = y
            @bottom = y + h

      origin:
         get: -> Point.new(@left, @top)
      corner:
         get: -> Point.new(@right, @bottom)
      extent:
         get: -> Point.new(@right - @left, @bottom - @top)
      
      'leftTop, topLeft':
         get: -> Point.new(@left, @top)
      'rightTop, topRight':
         get: -> Point.new(@right, @top)
      'leftBottom, bottomLeft':
         get: -> Point.new(@left, @bottom)
      'rightBottom, bottomRight':
         get: -> Point.new(@right, @bottom)
      leftCenter:
         get: -> Point.new @left, @center.y
      rightCenter:
         get: -> Point.new @right, @center.y
      topCenter:
         get: -> Point.new @center.x, @top
      bottomCenter:
         get: -> Point.new @center.x, @bottom
      type:
         get: -> util.getName(@constructor)
      center:
         get: -> @origin.translate @extent.scale(0.5)

   # width_: (h) -> @right = @left + h; this
   # height_: (v) -> bottom = @top + v; this
   # top_: (t) -> h = @h; @top = t; @bottom = t + h; this

   copy: -> new @constructor( @left, @top, @right, @bottom )
   inspect: -> "#{@type}( #{@asString()} )"

   asString: (opts) -> 
      "#{@left}, #{@top}, #{@width}, #{@height}"

   asPolygon: ->
      Polygon = require './Polygon'
      Polygon [@leftTop, @rightTop, @rightBottom, @leftBottom]...

   rotate: (angle) ->
      @asPolygon().rotateAbout( angle, @leftTop )

   lineSegments: ->
      Line = require './Line'
      {
         left: new Line( @leftTop, @leftBottom )
         right: new Line( @rightTop, @rightBottom )
         top: new Line( @topLeft, @topRight )
         bottom: new Line( @bottomLeft, @bottomRight )
      }

   closestPointOnShape: (aPoint) ->
      aPoint = Point.new arguments...
      segment = @closestShapeSegment(aPoint)
      segment.closestPointOnSegment(aPoint)

   closestShapeSegment: (aPoint) ->
      aPoint = Point.new arguments...
      minDist = Infinity
      closestSegment = null
      for key, segment of @lineSegments()
         pt = segment.closestPointOnSegment(aPoint)
         dist = pt.distTo(aPoint)
         if dist < minDist
            minDist = dist
            closestSegment = segment
      closestSegment

   svgString: (opts = {}) ->
      svg = if opts.ccw or opts.inside or /^cc|counter|inside/.test(opts.direction or opts.wind) 
         [
            "l 0, #{@height}"
            "l #{@width}, 0 "
            "l 0, -#{@height}"
         ]
      else
         [
            "l #{@width}, 0 "
            "l 0, #{@height}"
            "l -#{@width}, 0" 
         ]
      svg.unshift "M #{@origin.asString()}"
      svg.push "z"
      svg.join '   '
   
   envelope: (offset = 3) -> @insetBy(-offset, -offset) 
   inflate: @::envelope

   moveBy: (h, v) -> 
      pt = Point.new arguments...
      new Rect(@left + pt.x, @top + pt.y, @right + pt.x, @bottom + pt.y)
   translate: @::moveBy
  
   moveTo: (aPoint) -> 
      aPoint = Point.new arguments...
      new Rect(aPoint.x, aPoint.y, @width + aPoint.x, @height + aPoint.y)
    
   resizeBy: (h, v) -> new Rect(@left, @top, @right + h, @bottom + v)
   
   scale: (factor) -> @resizeTo(@w*factor, @h*factor)
  
   resizeTo: (h, v) -> new Rect(@left, @top, @left + h, @top + v)
  
   insetBy: (h, v) -> 
      v ?= h
      new Rect(@left + h, @top + v, @right - h, @bottom - v)
  
   insetAll: (a, b, c, d) -> new Rect(@left + a, @top + b, @right - c, @bottom - d)
  
   contains: (aPoint) -> 
      {x, y} = aPoint
      (@left <= x <= @right) and
      (min(@bottom, @top) <= y <= max(@bottom, @top))
   
   includes: (aRect) -> 
      aRect = Rect.new aRect
      switch
         when aRect.right > @right then no
         when aRect.bottom > @bottom then no
         when aRect.left < @left then no
         when aRect.top < @top then no
         else yes
   
   intersects: (aRect) -> 
      aRect = Rect.new aRect
      switch
         when aRect.right < @left then no
         when aRect.bottom < @top then no
         when aRect.left > @right then no
         when aRect.top > @bottom then no
         else yes

   positionComparedTo: (aRect, opts={}) ->
      aRect = Rect.new aRect
      opts.referencePoint ?= 'center'
      opts.flipY ?= no
      pt = @[opts.referencePoint]
      otherPt = aRect[opts.referencePoint]
      below = if opts.flipY then otherPt.y > pt.y else otherPt.y < pt.y
      above = if opts.flipY then otherPt.y < pt.y else otherPt.y > pt.y
      yAligned = pt.y is otherPt.y
      leftOf = pt.x > otherPt.x
      rightOf = pt.x < otherPt.x
      xAligned = pt.x is otherPt.x

      {
         below
         above
         leftOf
         rightOf
         xAligned
         yAligned
      }

   randomPoint: ->
      crypto = require 'crypto'
      pt = @origin
      buf = crypto.randomBytes(4)
      randX = @width * buf.readUInt16LE(0)/65536
      randY = @height * buf.readUInt16LE(2)/65536
      pt.moveBy(randX, randY)


   @infinite: -> new Rect(Infinity, Infinity, -Infinity, -Infinity)

   @new: (arg0, arg1, arg2, arg3) ->
      switch
         when arg0 instanceof Rect   then arg0
         when Point.quacksLikeAPoint(arg0) 
            p0 = Point.new(arg0)
            if Point.quacksLikeAPoint(arg1)
               p1 = Point.new(arg1)
               new Rect(
                  min( p0.x, p1.x)
                  min( p0.y, p1.y)
                  max( p0.x, p1.x)
                  max( p0.y, p1.y)
               )
            else if isNumber(arg1, arg2)
               wid = arg1
               hgt = arg2
               new Rect(
                  p0.x
                  p0.y
                  p0.x + wid
                  p0.y + hgt
               )
            else if (isNumber(arg0.w ? arg0.width, arg0.h ? arg0.height))
               wid = arg0.w ? arg0.width
               hgt = arg0.h ? arg0.height
               new Rect(
                  p0.x
                  p0.y
                  p0.x + wid
                  p0.y + hgt
               )
            else
               new Rect p0.x, p0.y, p0.x, p0.y
         else
            new Rect arguments...

module.exports = Rect

if require.main is module
   {exec} = require('child_process')
   exec 'cake build', (error, stdout, stderr) -> 
      console.log {error, stdout, stderr}
      # require '../test/test'

   r = Rect.new [0,0], 10, 3
   r = Rect.new {x: 1, y: 0, w: 10, h: 1}
   r = Rect.new {x: 1, y: 0, w: 10, h: 1}
   r = Rect.new {x: 1, y: 0}
   # r.x += 5
   # r.x += 5
   console.log r
   # console.log r.svgString()
   # console.log r.svgString(ccw: yes)
   # console.log r.envelope()
   # console.log r.center
   # console.log r.copy()
   # console.log r.inflate(3).lineSegments()
   # console.log r.moveTo(Point.new(3,3))
   # console.log r.closestShapeSegment [5, 15]
   # console.log r.closestPointOnShape [5,15]
   for i in [0..10]
      console.log i, r.randomPoint()


