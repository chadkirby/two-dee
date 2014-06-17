{sin, cos, atan2, sqrt, abs, PI} = Math

util = require './utilities'
{
   isNumber 
   fuzzyEqual
   hypot
} = util
{defineProperty} = Object


NumberPair = require './NumberPair'

class Complex extends NumberPair
   constructor: (real, imag) -> 
      unless this instanceof Complex
         return new Complex(real, imag)
      super real, imag

      # define own properties (enables 'for own key, val of point')
      defineProperty @, 'real', 
         enumerable: yes
         get: -> @[0]
         set: (val) -> @[0] = val

      defineProperty @, 'imag', 
         enumerable: yes
         get: -> @[1]
         set: (val) -> @[1] = val

   defProp = util.defProp.bind(@)

   defProp 
      'magnitude, rho': 
         get: (-> hypot( @real, @imag))
         set: (new_real) -> 
            {@real, @imag} = @asPolar().rho_(new_real).asComplex()

      'angle, phase, theta': 
         get: (-> atan2(@imag, @real))
         set: (new_theta) -> 
            {@real, @imag} = @asPolar().theta_(new_theta).asComplex()

   asComplex: -> this
   asPolar: -> 
      Polar = require './Polar'
      new Polar @rho, @theta

   neg: -> new @constructor( -@real, -@imag )
   conjugate: -> new @constructor( @real, -@imag )

   plus: (aNumber) ->
      aNumber = @constructor.new arguments...
      new @constructor( @real + aNumber.real, @imag + aNumber.imag)
   add: @::plus

   minus: (aNumber) ->
      aNumber = @constructor.new arguments...
      new @constructor( @real - aNumber.real, @imag - aNumber.imag)
   subtract: @::minus

   times: (aNumber) ->
      aNumber = @constructor.new arguments...
      new @constructor(
         (@real * aNumber.real) - (@imag * aNumber.imag),
         (@real * aNumber.imag) + (@imag * aNumber.real)
      )
   multiply: @::times

   div: (aNumber) ->
      aNumber = @constructor.new arguments...
      yr = aNumber.real;
      yi = aNumber.imag
      denom = 1 / (yr * yr + (yi * yi))
      new @constructor(
         ((@real * yr) + (@imag * yi)) * denom, 
         ((@imag * yr) - (@real * yi)) * denom
      )
   dividedBy: @::div

   @new: (real, imag) ->
      switch
         when real instanceof Complex   then real
         when real.asComplex?   then real.asComplex()
         when isNumber( real[0], real[1] )       then new Complex real[0], real[1]
         when isNumber( real.real, real.imag )   then new Complex real.real, real.imag
         when isNumber( real, imag )           then new Complex real, imag
         when isNumber( real )           then new Complex real, 0
         else
            throw "Complex.new requires numeric real and imag; got #{real} and #{imag}"
            null

module.exports = Complex
