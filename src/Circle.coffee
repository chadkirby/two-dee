{sin, cos, atan2, sqrt, abs, max, min, PI, round, ceil} = Math
Rect = require './Rect'

util = require './utilities'

{
   isNumber 
   fuzzyEqual
   hypot
   roundTo
   square
} = util

Point = require './Point2d'

class Circle
   defProp = util.defProp.bind(@)

   constructor: (center, @radius = 1) ->
      @center = Point.new(center)

   pointAt: (angle) ->
      new Point @center.x + @radius * angle.cos, @center.y + @radius * angle.sin

   svgString: ->
      """
         M #{@center}
         m -#{@radius}, 0
         a #{@radius},#{@radius} 0 1,0 #{@radius*2},0
         a #{@radius},#{@radius} 0 1,0 -#{@radius*2},0
      """
   envelope: (offset = 0) -> Rect(@center.x - @radius - offset, @center.y - @radius - offset, @center.x + @radius + offset, @center.y + @radius + offset)

module.exports = Circle
