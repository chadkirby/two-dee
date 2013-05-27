chai = require 'chai'  
chai.should()  
Point = require '../src/Point2d'
{PI} = Math
degrad = (me) -> me * 0.017453292519943295

describe '2d Point', ->  
  p = Point(0,1)
  origin = Point.origin
  it 'should have x any y values', ->  
    p.x.should.equal 0  
    p.y.should.equal 1  

  it '.new should accept point-like arguments', ->  
    p = Point(0,1)
    Point.new( p ).should.equal p
    Point.new( 0, 1 ).isEq(p).should.equal yes
    Point.new( [0, 1] ).isEq(p).should.equal yes
    Point.new( {x: 0, y:1} ).isEq(p).should.equal yes
    Point.new(0).isEq([0,0]).should.equal yes

  it 'should behave as an array', ->  
    p[0].should.equal 0 
    p[1].should.equal 1 
    arr = (val for val in p)
    arr[0].should.equal p.x
    arr[1].should.equal p.y
    (arr[2]?).should.equal no

  it 'should behave as an object', ->  
    arr = (val for own key, val of p)
    arr[0].should.equal p.x
    arr[1].should.equal p.y
    (arr[2]?).should.equal no
    arr = (key for own key, val of p)
    arr[0].should.equal 'x'
    arr[1].should.equal 'y'

  it 'should operate as polar', ->
    p.rho.should.equal 1
    p.magnitude.should.equal 1
    p.theta.should.equal PI/2
    p.angle.should.equal PI/2
    p.rho_(2).y.should.equal 2
    p.theta_(0).isFuzzyEq([2,0], 1e-10).should.equal yes

  it 'should test equality', ->
    p =  Point( 0 , 1)
    p1 = Point(0.1, 1)
    p.isEq(p1).should.equal no
    p.isFuzzyEq(p1, 0.01).should.equal no
    p.isFuzzyEq(p1, 0.1).should.equal yes
    p.isFuzzyEq(p1, 1).should.equal yes

  it 'should have absolute value', ->
      Point(-1, -1).abs.isEq([1,1]).should.equal yes
      Point(0, -1).abs.isEq([0,1]).should.equal yes

  it 'should have negated value', ->
      Point(-1, 0).neg.isEq([1,0]).should.equal yes
      Point(0, 1).neg.isEq([0,-1]).should.equal yes

  it 'should have transposed value', ->
      Point(-1, 0).transpose.isEq([0,-1]).should.equal yes

  it 'should have string value', ->
      Point(-1, 0).asString.should.equal "-1, 0"
      Point(-1, 0).inspect().should.equal "Point2d( -1, 0 )"

  it 'should support point addition', ->
    p1 =  Point( 0 , 1 )
    p2 =  Point( 1 , 1 )
    p1.plus(p2).asString.should.equal "1, 2"
    p1.translate(p2).asString.should.equal "1, 2"
    p1.plus(2).asString.should.equal "2, 3"
    p1.plus([2,3]).asString.should.equal "2, 4"

  it 'should support point subtraction', ->
    p1 =  Point( 0 , 1 )
    p2 =  Point( 1 , 1 )
    p1.minus(p2).asString.should.equal "-1, 0"
    p1.minus(2).asString.should.equal "-2, -1"
    p1.minus([2,3]).asString.should.equal "-2, -2"

  it 'should support point division', ->
    p1 =  Point( 0 , 1 )
    p2 =  Point( 1 , 1 )
    p1.div(p2).asString.should.equal "0, 1"
    p1.div(2).asString.should.equal "0, 0.5"
    p1.div([2,4]).asString.should.equal "0, 0.25"

  it 'should support point multiplication', ->
    p1 =  Point( 0 , 1 )
    p2 =  Point( 2 , 3 )
    p1.scale(p2).asString.should.equal "0, 3"
    p1.times(p2).asString.should.equal "0, 3"
    p1.scale(2).asString.should.equal "0, 2"
    p1.scale([2,3]).asString.should.equal "0, 3"

  it 'should roundTo a quantum', ->
    p1 =  Point( 1 , 0 ).rotate(degrad 90)
    [x,y] = p1.round(1e-10)
    x.should.equal 0
    y.should.equal 1
    [x,y] = p1.round(1)
    x.should.equal 0
    y.should.equal 1
    p1 = Point(1/3, 1/3)
    [x,y] = p1.round(1/2, 1/4)
    x.should.equal 0.5
    y.should.equal 0.25

  it 'should modulo', ->
    p1 =  Point( 2 , 5 )
    [x,y] = p1.mod(3)
    x.should.equal 2
    y.should.equal 2

  it 'should support rotation', ->
    p1 =  Point( 1 , 0 )
    rsqrt2 = 1 / Math.sqrt 2
    p1.rotate(degrad 45).isFuzzyEq( rsqrt2, rsqrt2, 1e-10).should.equal yes
    p1.rotate(degrad 90).isFuzzyEq( [0,1], 1e-10).should.equal yes
    p1.rotate(degrad -90).isFuzzyEq( {x: 0, y: -1}, 1e-10).should.equal yes

  it 'should compute distance to a point', ->
    p1 =  Point( 1 , 0 )
    sqrt2 = Math.sqrt 2
    p1.dist([0,0]).should.equal 1
    p1.rotate(degrad 45).dist([0,0]).should.equal 1
    p1.dist([0,1]).should.equal sqrt2

  it 'should compute angle to a point', ->
    p1 =  Point( 0, 0 )
    sqrt2 = Math.sqrt 2
    p1.angleToDeg([1,0]).should.equal 0
    p1.angleToDeg([2,2]).should.equal 45
    p1.angleToDeg([0,2]).should.equal 90

  it 'should be subclassable', ->
    class MyPoint extends Point
     constructor: (x, y, argfoo = "foo") -> 
        unless this instanceof MyPoint
           return new MyPoint(x, y)
        super
        @foo = argfoo

      @new: -> 
        pt = Point.new arguments...
        new MyPoint(pt.x, pt.y)

      div: -> "bar" # override method
      baz: -> "bat"

    p1 =  MyPoint( 0, 1, "foo" )
    p1.x.should.equal 0
    p1.y.should.equal 1
    p1.foo.should.equal "foo"
    p1.baz().should.equal "bat"

    p1 =  MyPoint.new( 0, 1 )
    p1.x.should.equal 0
    p1.y.should.equal 1
    p1.foo.should.equal "foo"

    p2 = p1.add(1).scale(2)
    p2.x.should.equal 2
    p2.y.should.equal 4
    p2.type.should.equal "MyPoint"
    p2.div().should.equal "bar"

  
# describe 'Number Parameter', ->  
#   p = Point.Number('foo', 3)
#   args = 
#   it 'should have a name', ->  
#     p.name.should.equal 'foo'  
#   it 'should have a default value', ->  
#     p.valueOf().should.equal 3  
#   it 'should consume a number argument', ->  
#     p.prepAndConsume(["hi", 1,2,3]).valueOf().should.equal 1

# describe 'Parameters', ->
#   parameters = Point.new(
#     foo: 3
#     bar: "hi"
#     baz: no
#     bat: []
#     )

