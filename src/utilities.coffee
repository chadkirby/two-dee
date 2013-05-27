isNumber = (objs...) -> 
   for obj in objs
      return no unless obj? and ((obj is +obj) or (toString.call(obj) is '[object Number]'))
   yes
{defineProperty} = Object

module.exports = 

   fuzzyEqual: (me, that, precision=0.001) -> 
      ( 1.0 - Math.abs(me - that)/precision ) >= 0

   hypot: (me, y) -> Math.sqrt(me*me + y*y)

   roundTo: (me, nearest=1) -> Math.round(me/nearest)*nearest

   getName: (obj) ->
      results = /function (.+?)\(/.exec(obj.toString())
      if results?.length > 1 
         results[1] 
      else 
         ""

   quacksLikeAPoint: (obj) ->
      if (
         isNumber( obj.x, obj.y ) or 
         isNumber( obj[0], obj[1] )
      ) 
         yes
      else
         no

   isNumber: isNumber

   defProp: (obj) ->
      for key, opts of obj
         names = key.split ','
         for name in names
            defineProperty @::, name.trim(), opts

   get: (obj) ->
      for key, fn of obj
         names = key.split ','
         for name in names
            defineProperty @::, name.trim(), get: fn
