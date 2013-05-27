chai = require 'chai'  
chai.should()  
Polar = require '../src/Polar'
{PI} = Math
degrad = (me) -> me * 0.017453292519943295

describe 'Polar', ->  
  p = Polar(0,1)
  origin = Polar.origin
  it 'should have x any y values', ->  
    p.rho.should.equal 0  
    p.theta.should.equal 1  

  it '.new should accept point-like arguments0', ->  
    p = Polar(0,1)
    Polar.new( p ).should.equal p
    Polar.new( 0, 1 ).isEq(p).should.equal yes

  it '.new should accept point-like arguments1', ->  
    p = Polar(0,1)
    Polar.new( [0, 1] ).isEq(p).should.equal yes
    Polar.new( {rho: 0, theta:1} ).isEq(p).should.equal yes

  it 'should behave as an array', ->  
    p[0].should.equal 0 
    p[1].should.equal 1 
    arr = (val for val in p)
    arr[0].should.equal p.rho
    arr[1].should.equal p.theta
    (arr[2]?).should.equal no

  it 'should behave as an object', ->  
    arr = (val for own key, val of p)
    arr[0].should.equal p.rho
    arr[1].should.equal p.theta
    (arr[2]?).should.equal no
    arr = (key for own key, val of p)
    arr[0].should.equal 'rho'
    arr[1].should.equal 'theta'

  it 'should operate as point', ->
    p = Polar(1,0)
    p.x.should.equal 1
    p.y.should.equal 0
    p.x_(2).rho.should.equal 2
    p.x_(0).y_(2).theta.should.equal PI/2

  it 'should test equality', ->
    p =  Polar( 0 , 1)
    p1 = Polar(0.1, 1)
    p.isEq(p1).should.equal no
    p.isFuzzyEq(p1, 0.01).should.equal no
    p.isFuzzyEq(p1, 0.1).should.equal yes
    p.isFuzzyEq(p1, 1).should.equal yes

  it 'should have negated value', ->
      Polar(1, 0).neg().asPoint().asString(round: 1e-10).should.equal "-1, 0"

  it 'should have string value', ->
      Polar(-1, 0).asString().should.equal "-1, 0"
      Polar(-1, 0).inspect().should.equal "Polar( -1, 0 )"

  it 'should support addition', ->
    p1 =  Polar( 1, 0 )
    p1.plus(1).asString().should.equal "2, 0"
    p1.plus(2).asString().should.equal "3, 0"

  it 'should support point subtraction', ->
    p1 =  Polar( 1, 0 )
    p1.minus(1).asString().should.equal "0, 0"
    p1.minus(2).asString().should.equal "-1, 0"

  it 'should support point division', ->
    p1 =  Polar( 2, 0 )
    p1.div(1).asString().should.equal "2, 0"
    p1.div(2).asString().should.equal "1, 0"
    p1 =  Polar( 2, PI )
    p1.div(2).asString(round: 1e-10).should.equal "-1, 0"

  it 'should scale', ->
    p1 =  Polar( 1 , 0 )
    p1.scale(2).asString().should.equal "2, 0"

  it 'should roundTo a quantum', ->
    p1 =  Polar( 4/3 , degrad(90) )
    [rho,theta] = p1.round(0.01)
    rho.should.equal 1.33
    theta.should.equal 1.57
    [rho,theta] = p1.round(1)
    rho.should.equal 1
    theta.should.equal 2
    [rho,theta] = p1.round(1/2, 1/4)
    rho.should.equal 1.5
    theta.should.equal 1.5

  it 'should modulo', ->
    p1 =  Polar( 2 , 5 )
    [x,y] = p1.mod(3)
    x.should.equal 2
    y.should.equal 2

  it 'should rotate', ->
    p1 =  Polar( 1 , 0 )
    rsqrt2 = 1 / Math.sqrt 2
    p1.rotate(degrad 45).asPoint().isFuzzyEq( rsqrt2, rsqrt2, 1e-10).should.equal yes
    p1.rotate(degrad 90).asPoint().isFuzzyEq( [0,1], 1e-10).should.equal yes
    p1.rotate(degrad -90).asPoint().isFuzzyEq( {x: 0, y: -1}, 1e-10).should.equal yes

  it 'should be subclassable', ->
    class MyPolar extends Polar
     constructor: (x, y, argfoo = "foo") -> 
        unless this instanceof MyPolar
           return new MyPolar(x, y)
        super
        @foo = argfoo

      @new: -> 
        pt = Polar.new arguments...
        new MyPolar(pt.rho, pt.theta)

      div: -> "bar" # override method
      baz: -> "bat"

    p1 =  MyPolar( 0, 1, "foo" )
    (p1 instanceof MyPolar).should.equal yes
    (p1 instanceof Polar).should.equal yes
    p1.rho.should.equal 0
    p1.theta.should.equal 1
    p1.foo.should.equal "foo"
    p1.baz().should.equal "bat"

    p1 =  MyPolar.new( 1, 0 )
    p1.rho.should.equal 1
    p1.theta.should.equal 0
    p1.foo.should.equal "foo"
    p1.div().should.equal "bar"

    p2 = p1.add(1).times(2)
    p2.rho.should.equal 4
    p2.theta.should.equal 0
    p2.type.should.equal "Complex"

  
# describe 'Number Parameter', ->  
#   p = Polar.Number('foo', 3)
#   args = 
#   it 'should have a name', ->  
#     p.name.should.equal 'foo'  
#   it 'should have a default value', ->  
#     p.valueOf().should.equal 3  
#   it 'should consume a number argument', ->  
#     p.prepAndConsume(["hi", 1,2,3]).valueOf().should.equal 1

# describe 'Parameters', ->
#   parameters = Polar.new(
#     foo: 3
#     bar: "hi"
#     baz: no
#     bat: []
#     )

