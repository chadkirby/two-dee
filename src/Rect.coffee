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
      @left = left
      @top = top
      @right = right
      @bottom = bottom

   defProp = util.defProp.bind(@)
   
   defProp 
      'width, w':
         get: -> @right - @left
         set: (h) -> @width_(h)
      'height, h':
         get: -> @bottom - @top
         set: (v) -> @height_(v)
      x: 
         get: -> @left
      y: 
         get: -> @top

      origin:
         get: -> Point.new(@left, @top)
      corner:
         get: -> Point.new(@right, @bottom)
      extent:
         get: -> Point.new(@right - @left, @bottom - @top)
      
      leftTop:
         get: -> Point.new(@left, @top)
      rightTop:
         get: -> Point.new(@right, @top)
      leftBottom:
         get: -> Point.new(@left, @bottom)
      rightBottom:
         get: -> Point.new(@right, @bottom)
      type:
         get: -> util.getName(@constructor)

   width_: (h) -> @right = @left + h; this
   height_: (v) -> @bottom = @top + v; this

   copy: -> new @constructor( @left, @right, @top, @bottom )
   inspect: -> "#{@type}( #{@asString()} )"

   asString: (opts) -> 
      "#{@left}, #{@top}, #{@right}, #{@bottom}"

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

   moveBy: (h, v) -> new Rect(@left + h, @top + v, @right + h, @bottom + v)
  
   moveTo: (aPoint) -> 
      aPoint = Point.new arguments...
      new Rect(aPoint.x, aPoint.y, @right - @left + aPoint.x, @bottom - @top + aPoint.y)
   translate: @::moveTo
    
   resizeBy: (h, v) -> new Rect(@left, @top, @right + h, @bottom + v)
  
   resizeTo: (h, v) -> new Rect(@left, @top, @left + h, @top + v)
  
   insetBy: (h, v) -> new Rect(@left + h, @top + v, @right - h, @bottom - v)
  
   insetAll: (a, b, c, d) -> new Rect(@left + a, @top + b, @right - c, @bottom - d)
  
   contains: (aPoint) ->  
      uitl.inclusivelyBetween( aPoint.x, @left, @right ) and
      uitl.inclusivelyBetween( aPoint.y, @bottom, @top )
   
   intersects: (aRect) -> 
      aRect = Rect.new aRect
      return no if aRect.right < @left
      return no if aRect.bottom < @top
      return no if aRect.left > @right
      return no if aRect.top > @bottom
      yes
   


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
         else
            new Rect arguments...

module.exports = Rect

if require.main is module
   r = Rect.new [0,0], 10, 3
   console.log r
   console.log r.svgString()
   console.log r.svgString(ccw: yes)
   console.log r.envelope()


