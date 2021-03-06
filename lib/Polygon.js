// Generated by CoffeeScript 1.9.1
var Line, PI, Point, Polygon, Rect, abs, atan2, cos, flatten, fuzzyEqual, hypot, isNumber, k, len, line, match, max, min, pt0, pt1, r, ref, ref1, roundTo, s, sin, sqrt, square, util,
  slice = [].slice;

sin = Math.sin, cos = Math.cos, atan2 = Math.atan2, sqrt = Math.sqrt, abs = Math.abs, max = Math.max, min = Math.min, PI = Math.PI;

util = require('./utilities');

isNumber = util.isNumber, fuzzyEqual = util.fuzzyEqual, hypot = util.hypot, roundTo = util.roundTo, square = util.square, flatten = util.flatten;

Point = require('./Point2d');

Line = require('./Line');

Rect = require('./Rect');

Polygon = (function() {
  var defProp;

  function Polygon() {
    var k, len, point, points;
    points = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    if (!(this instanceof Polygon)) {
      return (function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return Object(result) === result ? result : child;
      })(Polygon, points, function(){});
    }
    this.points = [];
    this._envelope = Rect.infinite();
    for (k = 0, len = points.length; k < len; k++) {
      point = points[k];
      this.push(point);
    }
  }

  Polygon.prototype.push = function(point) {
    return this.setAt(this.points.length, point);
  };

  Polygon.prototype.setAt = function(index, point) {
    var pt;
    pt = Point["new"](point);
    if (pt.x < this._envelope.left) {
      this._envelope.left = pt.x;
    }
    if (pt.y < this._envelope.top) {
      this._envelope.top = pt.y;
    }
    if (pt.x > this._envelope.right) {
      this._envelope.right = pt.x;
    }
    if (pt.y > this._envelope.bottom) {
      this._envelope.bottom = pt.y;
    }
    return this.points[index] = pt;
  };

  Polygon.prototype.addOffsetPoint = function(offset) {
    var pt, ref;
    pt = (ref = this.last()).translate.apply(ref, arguments);
    return this.push(pt);
  };

  defProp = util.defProp.bind(Polygon);

  Polygon.prototype.last = function() {
    return this.points[this.length - 1];
  };

  defProp({
    right: {
      get: function() {
        return this._envelope.right;
      }
    },
    left: {
      get: function() {
        return this._envelope.left;
      }
    },
    top: {
      get: function() {
        return this._envelope.top;
      }
    },
    bottom: {
      get: function() {
        return this._envelope.bottom;
      }
    },
    length: {
      get: function() {
        return this.points.length;
      }
    },
    'width, w': {
      get: function() {
        return this._envelope.width;
      }
    },
    'height, h': {
      get: function() {
        return this._envelope.height;
      }
    },
    x: {
      get: function() {
        return this._envelope.left;
      }
    },
    y: {
      get: function() {
        return this._envelope.top;
      }
    },
    origin: {
      get: function() {
        return this._envelope.origin;
      }
    },
    corner: {
      get: function() {
        return this._envelope.corner;
      }
    },
    extent: {
      get: function() {
        return this._envelope.extent;
      }
    },
    leftTop: {
      get: function() {
        return this._envelope.leftTop;
      }
    },
    rightTop: {
      get: function() {
        return this._envelope.rightTop;
      }
    },
    leftBottom: {
      get: function() {
        return this._envelope.leftBottom;
      }
    },
    rightBottom: {
      get: function() {
        return this._envelope.rightBottom;
      }
    },
    type: {
      get: function() {
        return util.getName(this.constructor);
      }
    }
  });

  Polygon.prototype.lineSegments = function() {
    var k, len, p0, p1, ref, segments;
    segments = [];
    ref = this.points;
    for (k = 0, len = ref.length; k < len; k++) {
      p1 = ref[k];
      if (typeof p0 !== "undefined" && p0 !== null) {
        segments.push(new Line(p0, p1));
      }
      p0 = p1;
    }
    segments.push(new Line(p0, this.points[0]));
    return segments;
  };

  Polygon.prototype.closestPointOnShape = function(aPoint) {
    var segment;
    aPoint = Point["new"].apply(Point, arguments);
    segment = this.closestShapeSegment(aPoint);
    return segment.closestPointOnSegment(aPoint);
  };

  Polygon.prototype.closestShapeSegment = function(aPoint) {
    var closestSegment, dist, k, len, minDist, pt, ref, segment;
    aPoint = Point["new"].apply(Point, arguments);
    minDist = Infinity;
    closestSegment = null;
    ref = this.lineSegments();
    for (k = 0, len = ref.length; k < len; k++) {
      segment = ref[k];
      pt = segment.closestPointOnSegment(aPoint);
      dist = pt.distTo(aPoint);
      if (dist < minDist) {
        minDist = dist;
        closestSegment = segment;
      }
    }
    return closestSegment;
  };

  Polygon.prototype.envelope = function(offset) {
    if (offset == null) {
      offset = 0;
    }
    return this._envelope.insetBy(-offset, -offset);
  };

  Polygon.prototype.controlPts = function(ptsPerSegment) {
    var denom, ii, k, l, len, line, out, ref, ref1;
    if (ptsPerSegment == null) {
      ptsPerSegment = 2;
    }
    out = [];
    denom = ptsPerSegment + 1;
    ref = this.lineSegments();
    for (k = 0, len = ref.length; k < len; k++) {
      line = ref[k];
      for (ii = l = 1, ref1 = ptsPerSegment; 1 <= ref1 ? l <= ref1 : l >= ref1; ii = 1 <= ref1 ? ++l : --l) {
        out.push(line.at(ii / denom));
      }
    }
    return out;
  };

  Polygon.prototype.inspect = function() {
    return this.type + "( " + (this.asString({
      fixed: 4
    })) + " )";
  };

  Polygon.prototype.asString = function(opts) {
    var out, point;
    out = (function() {
      var k, len, ref, results;
      ref = this.points;
      results = [];
      for (k = 0, len = ref.length; k < len; k++) {
        point = ref[k];
        results.push(point.asString(opts));
      }
      return results;
    }).call(this);
    return "[" + (out.join('], [')) + "]";
  };

  Polygon.prototype.svgString = function(opts) {
    var ii, pt, svg;
    if (opts == null) {
      opts = {};
    }
    svg = (function() {
      var k, len, ref, results;
      ref = this.points;
      results = [];
      for (ii = k = 0, len = ref.length; k < len; ii = ++k) {
        pt = ref[ii];
        results.push(pt.asString(opts));
      }
      return results;
    }).call(this);
    return "M" + (svg.join('  L')) + " z";
  };

  Polygon.prototype.map = function(fn) {
    var ii, k, len, pt, ref, results;
    ref = this.points;
    results = [];
    for (ii = k = 0, len = ref.length; k < len; ii = ++k) {
      pt = ref[ii];
      results.push(fn(pt, ii));
    }
    return results;
  };

  Polygon.prototype.moveBy = function(h, v) {
    var pts;
    pts = this.map(function(pt) {
      return pt.translate(h, v);
    });
    return (function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args);
      return Object(result) === result ? result : child;
    })(this.constructor, pts, function(){});
  };

  Polygon.prototype.translate = Polygon.prototype.moveBy;

  Polygon.prototype.moveTo = function(aPoint) {
    var delta;
    aPoint = Point["new"].apply(Point, arguments);
    delta = aPoint.minus(this.points[0]);
    return this.moveBy(delta);
  };

  Polygon.prototype.scaleAbout = function(scale, origin) {
    var pts;
    scale = Point["new"](scale);
    pts = this.map(function(pt) {
      return pt.scaleAbout(scale, origin);
    });
    return (function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args);
      return Object(result) === result ? result : child;
    })(this.constructor, pts, function(){});
  };

  Polygon.prototype.rotateAbout = function(rotate, origin) {
    var pts;
    pts = this.map(function(pt) {
      return pt.rotateAbout(rotate, origin);
    });
    return (function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args);
      return Object(result) === result ? result : child;
    })(this.constructor, pts, function(){});
  };

  Polygon.prototype.scale = function(h, v) {
    var origin, pts, scale;
    scale = Point["new"].apply(Point, arguments);
    origin = this.points[0];
    pts = this.map(function(pt) {
      return pt.scaleAbout(scale, origin);
    });
    return (function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args);
      return Object(result) === result ? result : child;
    })(this.constructor, pts, function(){});
  };

  Polygon.prototype.resizeBy = Polygon.prototype.scale;

  Polygon.prototype.area = function() {
    var area, i, j, nPts, p1, p2, pts;
    area = 0;
    pts = this.points;
    nPts = pts.length;
    j = nPts - 1;
    p1 = void 0;
    p2 = void 0;
    i = 0;
    while (i < nPts) {
      p1 = pts[i];
      p2 = pts[j];
      area += p1.x * p2.y;
      area -= p1.y * p2.x;
      j = i++;
    }
    area /= 2;
    return area;
  };

  Polygon.prototype.centroid = function() {
    var f, i, j, nPts, p1, p2, pts, x, y;
    pts = this.points;
    nPts = pts.length;
    x = 0;
    y = 0;
    f = void 0;
    j = nPts - 1;
    p1 = void 0;
    p2 = void 0;
    i = 0;
    while (i < nPts) {
      p1 = pts[i];
      p2 = pts[j];
      f = p1.x * p2.y - p2.x * p1.y;
      x += (p1.x + p2.x) * f;
      y += (p1.y + p2.y) * f;
      j = i++;
    }
    f = this.area() * 6;
    return Point["new"](x / f, y / f);
  };

  return Polygon;

})();

module.exports = Polygon;

if (require.main === module) {
  r = Polygon([61.427898, 72.746506]);
  s = "l13.11,-25.45 \nl2.74,-46.09  \nl-21.956,-0.46 \nl-24.6,3.8  \nl3.94,62.26 ";
  ref = s.split('\n');
  for (k = 0, len = ref.length; k < len; k++) {
    line = ref[k];
    ref1 = /l(.+),(.+)/.exec(line), match = ref1[0], pt0 = ref1[1], pt1 = ref1[2];
    r.addOffsetPoint(+pt0, +pt1);
  }
  console.log(r.scale(0.5).translate(5, 5).controlPts(1));
  console.log(r.moveBy(10, 10));
  console.log(r.controlPts(1));
  console.log(r.svgString({
    fixed: 4
  }));
  console.log(r.envelope);
  console.log(r.area(), r.centroid());
  console.log(r.rotateAbout(Math.PI, r.centroid()));
}
