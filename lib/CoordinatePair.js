// Generated by CoffeeScript 1.6.2
var CoordinatePair, PI, abs, atan2, cos, defineProperty, fuzzyEqual, hypot, isNumber, max, min, p, roundTo, sin, sqrt, util;

sin = Math.sin, cos = Math.cos, atan2 = Math.atan2, sqrt = Math.sqrt, abs = Math.abs, max = Math.max, min = Math.min, PI = Math.PI;

util = require('./utilities');

isNumber = util.isNumber, fuzzyEqual = util.fuzzyEqual, hypot = util.hypot, roundTo = util.roundTo;

defineProperty = Object.defineProperty;

CoordinatePair = (function() {
  var defProp, get;

  function CoordinatePair(coordinates) {
    this.coordinates = coordinates;
  }

  CoordinatePair.prototype.copy = function() {
    return this.constructor["new"]([this.coordinates[0], this.coordinates[1]]);
  };

  defProp = util.defProp.bind(CoordinatePair);

  defProp({
    coordinates: {
      enumerable: false
    },
    0: {
      get: (function() {
        return this.coordinates[0];
      }),
      set: (function(val) {
        return this.coordinates[0] = val;
      })
    },
    1: {
      get: (function() {
        return this.coordinates[1];
      }),
      set: (function(val) {
        return this.coordinates[1] = val;
      })
    }
  });

  get = util.get.bind(CoordinatePair);

  get({
    asString: function() {
      return "" + this.coordinates[0] + ", " + this.coordinates[1];
    }
  });

  get({
    asArray: function() {
      var val, _i, _len, _ref, _results;

      _ref = this.coordinates;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        val = _ref[_i];
        _results.push(val);
      }
      return _results;
    }
  });

  get({
    type: function() {
      return util.getName(this.constructor);
    }
  });

  CoordinatePair.prototype.toString = function() {
    return this.asString;
  };

  CoordinatePair.prototype.inspect = function() {
    return "" + this.type + "( " + this.asString + " )";
  };

  defineProperty(CoordinatePair.prototype, 'length', {
    value: 2
  });

  CoordinatePair.prototype.set = function(arg0, arg1) {
    if (arg0 != null) {
      this.coordinates[0] = arg0;
    }
    if (arg1 != null) {
      this.coordinates[1] = arg1;
    }
    return this;
  };

  CoordinatePair.prototype.isEq = function() {
    var that, _ref;

    that = (_ref = this.constructor)["new"].apply(_ref, arguments);
    if (that == null) {
      return false;
    }
    return (that[0] === this[0]) && (that[1] === this[1]);
  };

  CoordinatePair.prototype.isFuzzyEq = function(that, precision) {
    var _ref;

    that = (_ref = this.constructor)["new"].apply(_ref, arguments);
    if (that == null) {
      return false;
    }
    if (arguments.length > 2) {
      precision = arguments[3];
    }
    return fuzzyEqual(that[0], this[0], precision) && fuzzyEqual(that[1], this[1], precision);
  };

  CoordinatePair.prototype.round = function() {
    var that;

    that = CoordinatePair["new"].apply(CoordinatePair, arguments);
    return this.constructor["new"](roundTo(this[0], that[0]), roundTo(this[1], that[1]));
  };

  CoordinatePair.prototype.mod = function() {
    var that;

    that = CoordinatePair["new"].apply(CoordinatePair, arguments);
    return new this.constructor(this[0] % that[0], this[1] % that[1]);
  };

  CoordinatePair["new"] = function(x, y) {
    switch (false) {
      case !(x instanceof CoordinatePair):
        return x;
      case !isNumber(x[0], x[1]):
        return new CoordinatePair([x[0], x[1]]);
      case !isNumber(x, y):
        return new CoordinatePair([x, y]);
      case !isNumber(x):
        return new CoordinatePair([x, x]);
      default:
        console.warn("CoordinatePair.new requires numeric inputss; got " + x + " and " + y);
        return null;
    }
  };

  return CoordinatePair;

})();

module.exports = CoordinatePair;

if (require.main === module) {
  p = new CoordinatePair([1 / 3, 1 / 3]);
  console.log(p, p[0], p[1]);
  console.log(p.round(1 / 2, 1 / 4));
}