{sin, cos, atan2, sqrt, abs, max, min, PI} = Math

util = require './utilities'

{
   isNumber 
   fuzzyEqual
   hypot
   roundTo
} = util

{defineProperty} = Object

class SegmentPaths
	constructor: (segmentArray) -> 
      if @ instanceof NumberPair
         Object.defineProperty @, '_segments',
            enumerable: no
            value: segmentArray[..]

   copy: -> new @constructor( @_segments )

   defProp = util.defProp.bind(@)
