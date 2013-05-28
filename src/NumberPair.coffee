{sin, cos, atan2, sqrt, abs, max, min, PI} = Math

util = require './utilities'

{
   isNumber 
   fuzzyEqual
   hypot
   roundTo
} = util

{defineProperty} = Object

class NumberPair
   constructor: (numberArray) -> 
      if @ instanceof NumberPair
         Object.defineProperty @, '_numPair',
            enumerable: no
            value: numberArray[0..1]

   copy: -> new @constructor( @_numPair )

   defProp = util.defProp.bind(@)

   defProp 
      0:
         get: (-> @_numPair[0]), 
         set: ((val) -> @_numPair[0] = val)
      1:
         get: (-> @_numPair[1]), 
         set: ((val) -> @_numPair[1] = val)
      length:
         value: 2
      type:
         get: -> util.getName(@constructor)

   asString: (opts) -> 
      if opts?.round?
         @round(opts.round).asString()
      else
         "#{@_numPair[0]}, #{@_numPair[1]}"

   asArray: -> @_numPair[..]

   toString: -> @::asString

   inspect: -> "#{@type}( #{@asString()} )"

   envelope: (offset = 3) -> 

   set: (arg0, arg1) -> 
      @_numPair[0] = arg0 if arg0?
      @_numPair[1] = arg1 if arg1?
      this

   isEq: -> 
      that = @constructor.new arguments...
      return no unless that?
      (that[0] is @[0]) and (that[1] is @[1])

   isFuzzyEq: (that, precision) -> 
      that = @constructor.new arguments...
      return no unless that?

      if arguments.length > 2 
         precision = arguments[3] # isEq(0, 0, 0.1)      

      fuzzyEqual(that[0], @[0], precision) and 
      fuzzyEqual(that[1], @[1], precision)

   round: ->
      that = NumberPair.new arguments...
      @constructor.new( 
         roundTo( @[0], that[0] ), 
         roundTo( @[1], that[1] ) 
      )
    
   mod: ->
      that = NumberPair.new arguments...
      new @constructor( @[0] % that[0], @[1] % that[1] )

   @new: (x, y) ->
      switch
         when x instanceof NumberPair   then x
         when isNumber( x[0], x[1] ) then new NumberPair [x[0], x[1]]
         when isNumber( x, y )       then new NumberPair [x, y]
         when isNumber( x )          then new NumberPair [x, x]
         else
            throw "NumberPair.new requires numeric inputss; got #{x} and #{y}"
            null

module.exports = NumberPair

if require.main is module
   p = new NumberPair([1/3,1/3])
   console.log p, p[0], p[1]
   console.log p.round(1/2, 1/4)

