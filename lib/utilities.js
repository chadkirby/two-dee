// Generated by CoffeeScript 1.6.2
var defineProperty, isNumber,
  __slice = [].slice;

isNumber = function() {
  var obj, objs, _i, _len;

  objs = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  for (_i = 0, _len = objs.length; _i < _len; _i++) {
    obj = objs[_i];
    if (!((obj != null) && ((obj === +obj) || (toString.call(obj) === '[object Number]')))) {
      return false;
    }
  }
  return true;
};

defineProperty = Object.defineProperty;

module.exports = {
  fuzzyEqual: function(me, that, precision) {
    if (precision == null) {
      precision = 0.001;
    }
    return (1.0 - Math.abs(me - that) / precision) >= 0;
  },
  hypot: function(me, y) {
    return Math.sqrt(me * me + y * y);
  },
  roundTo: function(me, nearest) {
    if (nearest == null) {
      nearest = 1;
    }
    return Math.round(me / nearest) * nearest;
  },
  getName: function(obj) {
    var results;

    results = /function (.+?)\(/.exec(obj.toString());
    if ((results != null ? results.length : void 0) > 1) {
      return results[1];
    } else {
      return "";
    }
  },
  quacksLikeAPoint: function(obj) {
    if (isNumber(obj.x, obj.y) || isNumber(obj[0], obj[1])) {
      return true;
    } else {
      return false;
    }
  },
  isNumber: isNumber,
  defProp: function(obj) {
    var key, name, names, opts, _results;

    _results = [];
    for (key in obj) {
      opts = obj[key];
      names = key.split(',');
      _results.push((function() {
        var _i, _len, _results1;

        _results1 = [];
        for (_i = 0, _len = names.length; _i < _len; _i++) {
          name = names[_i];
          _results1.push(defineProperty(this.prototype, name.trim(), opts));
        }
        return _results1;
      }).call(this));
    }
    return _results;
  },
  get: function(obj) {
    var fn, key, name, names, _results;

    _results = [];
    for (key in obj) {
      fn = obj[key];
      names = key.split(',');
      _results.push((function() {
        var _i, _len, _results1;

        _results1 = [];
        for (_i = 0, _len = names.length; _i < _len; _i++) {
          name = names[_i];
          _results1.push(defineProperty(this.prototype, name.trim(), {
            get: fn
          }));
        }
        return _results1;
      }).call(this));
    }
    return _results;
  }
};