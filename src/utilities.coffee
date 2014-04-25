isNumber = (objs...) -> 
   for obj in objs
      return no unless obj? and ((obj is +obj) or (toString.call(obj) is '[object Number]'))
   yes
{defineProperty} = Object

flatten = (array) -> # from underscore
   array.reduce (memo, value) ->
      return memo.concat(flatten(value)) if Array.isArray value
      memo.push value
      memo
   , []

module.exports = 

   fuzzyEqual: (me, that, precision=0.001) -> 
      ( 1.0 - Math.abs(me - that)/precision ) >= 0

   hypot: (me, y) -> Math.sqrt(me*me + y*y)

   square: (val) -> val * val

   roundTo: (me, nearest=1) -> Math.round(me/nearest)*nearest

   exclusivelyBetween: (me, lo, hi) -> lo < me < hi
   inclusivelyBetween: (me, lo, hi) -> lo <= me <= hi


   getName: (obj) ->
      results = /function (.+?)\(/.exec(obj.toString())
      if results?.length > 1 
         results[1] 
      else 
         ""

   isNumber: isNumber

   defProp: (obj) ->
      for key, opts of obj
         names = key.split ','
         for name in names
            name = name.trim()
            defineProperty @::, name, opts
            if opts.set? 
               # create chainable setter function, called by name_(). 
               # eg, line.length = 7 is the same as line.length_(7)
               do(name) =>
                  defineProperty @::, name + "_", value: (val) -> this[name] = val; this

   get: (obj) ->
      for key, fn of obj
         names = key.split ','
         for name in names
            defineProperty @::, name.trim(), get: fn

   flatten: flatten

   doPairs: (obj, fn) ->
      unless fn?
         fn = (a,b,i,i1,i2) -> [a,b]
      i = 0
      for key, val of obj when (not isNaN(n = parseInt(key))) and obj[n+1]?
         fn.call(obj, val, obj[1+n], i++, n, 1+n)

   clump: (arr, n=2) -> for j in [0...arr.length] by n
      for i in [0...n] when (i+j) < arr.length
         arr[i+j] 
