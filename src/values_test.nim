###############################################################################
##                                                                           ##
##                     nim-values library                                    ##
##                                                                           ##
##   (c) Christoph Herzog <chris@theduke.at> 2015                            ##
##                                                                           ##
##   This project is under the LGPL license.                                 ##
##   Check LICENSE.txt for details.                                          ##
##                                                                           ##
###############################################################################

import macros, typetraits, sets, times
from std/json import nil

import unittest

{.experimental: "dotOperators".}
import values

macro testType(): untyped =
  result = quote do:
    type TestTyp = ref object of RootObj
      strField: string
      intField: int
      floatField: float
      boolField: bool

  var acs = buildAccessors(result[0])
  result = newStmtList(result)
  result.add acs

testType()

suite("Values"):

  test "Value":

    test "toValue(Ref)(), type checkers and accessors":
      test "Should work for bool":
        assert toValue(true).isBool()
        assert toValue(true).getBool()
        assert toValue(true).asBool()
        assert toValue(true)[bool]

        assert toValueRef(true).isBool()
        assert toValueRef(true).getBool()
        assert toValueRef(true).asBool()
        assert toValueRef(true)[bool]

      test "Should work for char":
        assert toValue('c').isChar()
        assert toValue('c').getChar() == 'c'
        assert toValue('c').asChar() == 'c'
        assert toValue('c')[char] == 'c'

        assert toValueRef('c').isChar()
        assert toValueRef('c').getChar() == 'c'
        assert toValueRef('c').asChar() == 'c'
        assert toValueRef('c')[char] == 'c'

      test "Should work for int":
        assert toValue(33'i8).isInt()
        assert toValue(33'i16).isInt()
        assert toValue(33'i32).isInt()
        assert toValue(33'i64).isInt()
        assert toValue(33).isInt()

        assert toValue(33).getInt() == 33
        assert toValue(33).asInt() == 33
        assert toValue(33)[int8] == 33'i8
        assert toValue(33)[int16] == 33'i16
        assert toValue(33)[int32] == 33'i32
        assert toValue(33)[int64] == 33'i64
        assert toValue(33)[int] == 33

        assert toValueRef(33).isInt()
        assert toValueRef(33).getInt() == 33
        assert toValueRef(33).asInt() == 33
        assert toValueRef(33)[int] == 33

      test "Should work for uint":
        assert toValue(33'u8).isUInt()
        assert toValue(33'u16).isUInt()
        assert toValue(33'u32).isUInt()
        assert toValue(33'u64).isUInt()
        assert toValue(33'u).isUInt()

        assert toValue(33'u).getUInt() == 33'u
        assert toValue(33'u).asUInt() == 33'u
        assert toValue(33'u)[uint8] == 33'u8
        assert toValue(33'u)[uint16] == 33'u16
        assert toValue(33'u)[uint32] == 33'u32
        assert toValue(33'u)[uint64] == 33'u64
        assert toValue(33'u)[uint] == 33'u

        assert toValueRef(33'u).isUInt()
        assert toValueRef(33'u).getUInt() == 33'u
        assert toValueRef(33'u).asUInt() == 33'u
        assert toValueRef(33'u)[uint] == 33'u

      test "Should work for float":
        assert toValue(33.33).isFloat()
        assert toValue(33'f32).isFloat()
        assert toValue(33'f64).isFloat()

        assert toValue(33.33).getFloat() == 33.33
        assert toValue(33.33).asFloat() == 33.33
        assert toValue(33.33)[float32] == 33.33'f32
        assert toValue(33.33)[float64] == 33.33'f64
        assert toValue(33.33)[float] == 33.33

        assert toValueRef(33.33).isFloat()
        assert toValueRef(33.33).getFloat() == 33.33
        assert toValueRef(33.33).asFloat() == 33.33
        assert toValueRef(33.33)[float] == 33.33

      test "Should work for string":
        assert toValue("string").isString()
        assert toValue("string").getString() == "string"
        assert toValue("string").asString() == "string"
        assert toValue("string")[string] == "string"

        assert toValueRef("string").isString()
        assert toValueRef("string").getString() == "string"
        assert toValueRef("string").asString() == "string"
        assert toValueRef("string")[string] == "string"

      test "Should work for time":
        var t = times.getTime()
        var ti = times.local(t)
        assert toValue(t).isTime()
        assert toValue(t).getTime() == ti
        assert toValue(t)[times.DateTime] == ti
        assert toValue(t)[times.Time] == t

        assert toValueRef(t).isTime()
        assert toValueRef(t).getTime() == ti
        assert toValueRef(t)[Time] == t

      test "Should work for sequence":
        var s = @[1, 2, 3]
        var vs = @[toValueRef(1), toValueRef(2), toValueRef(3)]
        assert toValue(s).isSeq()
        assert toValue(s).getSeq() == vs
        assert toValue(s).asSeq(int) == s

        assert toValueRef(s).isSeq()
        assert toValueRef(s).getSeq() == vs
        assert toValueRef(s).asSeq(int) == s

      test "Should work for array":
        var a = [1, 2, 3]
        var vs = @[toValueRef(1), toValueRef(2), toValueRef(3)]
        assert toValue(a).isSeq()
        assert toValue(a).getSeq() == vs

        assert toValueRef(a).isSeq()
        assert toValueRef(a).getSeq() == vs

      test "Should work for set":
        var a = {1, 2, 3}
        var vs = @[toValueRef(1), toValueRef(2), toValueRef(3)]
        assert toValue(a).isSet()
        assert toValue(a).getSeq() == vs

        assert toValueRef(a).isSet()
        assert toValueRef(a).getSeq() == vs

      test "Should work for map":
        var t = (s: "s", i: 1, f: 1.1)
        var m = toValueRef(t)
        assert m.isMap()
        assert m.s == "s"
        assert m.i == 1
        assert m.f == 1.1

    test "isZero()":
      test "Should work for int":
        assert toValue(0).isZero()
        assert not toValue(1).isZero()

        assert toValueRef(0).isZero()
        assert not toValueRef(1).isZero()

      test "Should work for uint":
        assert toValue(0'u).isZero()
        assert not toValue(1'u).isZero()

        assert toValueRef(0'u).isZero()
        assert not toValueRef(1'u).isZero()

      test "Should work for float":
        assert toValue(0.0).isZero()
        assert not toValue(1.1).isZero()

        assert toValueRef(0.0).isZero()
        assert not toValueRef(1.1).isZero()

      test "Should work for string":
        var s: string
        assert toValue(s).isZero()
        assert toValue("").isZero()
        assert not toValue("a").isZero()

        assert toValueRef(s).isZero()
        assert toValueRef("").isZero()
        assert not toValueRef("a").isZero()

    test ".len()":
      test "Should work for char":
        assert toValue(' ').len() == 1
        assert toValueRef(' ').len() == 1

      test "Should work for string":
        assert toValue("abc").len() == 3
        assert toValueRef("abc").len() == 3

      test "Should work for seq":
        assert toValue(@[1, 2, 3]).len() == 3
        assert toValueRef(@[1, 2, 3]).len() == 3

      test "Should work for set":
        assert toValue({1, 2, 3}).len() == 3
        assert toValueRef({1, 2, 3}).len() == 3

      test "Should work for map":
        assert toValueRef((a: 1)).len() == 1

    test "`==`":
      test "Should work for bool":
        assert toValue(true) == toValue(true)
        assert toValue(true) == true

        assert toValueRef(false) == toValueRef(false)
        assert toValueRef(true) == toValue(true)
        assert toValue(true) == toValueRef(true)
        assert toValueRef(false) == false

      test "Should work for char":
        assert toValue(' ') == toValue(' ')
        assert toValue(' ') == ' '

        assert toValueRef(' ') == toValueRef(' ')
        assert toValueRef(' ') == toValue(' ')
        assert toValue(' ') == toValueRef(' ')
        assert toValueRef(' ') == ' '

      test "Should work for string":
        assert toValue("a b c") == toValue("a b c")
        assert toValue("a b c") == "a b c"

        assert toValueRef("a b c") == toValueRef("a b c")
        assert toValueRef("a b c") == toValue("a b c")
        assert toValue("a b c") == toValueRef("a b c")
        assert toValueRef("a b c") == "a b c"

      test "Should work for int":
        assert toValue(5) == toValue(5)
        assert toValue(5) == 5

        assert toValueRef(5) == toValueRef(5)
        assert toValueRef(5) == toValue(5)
        assert toValue(5) == toValueRef(5)
        assert toValueRef(5) == 5


      test "Should work for uint":
        assert toValue(5'u) == toValue(5'u)
        assert toValue(5'u) == 5'u

        assert toValueRef(5'u) == toValueRef(5'u)
        assert toValueRef(5'u) == toValue(5'u)
        assert toValue(5'u) == toValueRef(5'u)
        assert toValueRef(5'u) == 5'u

      test "Should work for float":
        assert toValue(5.5) == toValue(5.5)
        assert toValue(5.5) == 5.5

        assert toValueRef(5.5) == toValueRef(5.5)
        assert toValueRef(5.5) == toValue(5.5)
        assert toValue(5.5) == toValueRef(5.5)
        assert toValueRef(5.5) == 5.5

      test "Should work for sequence":
        var s = ValueSeq(1, 2, 3)
        assert s == ValueSeq(1, 2, 3)
        assert s == @[1, 2, 3]
        assert s == [1, 2, 3]

        assert toValueRef(5.5) == toValueRef(5.5)
        assert toValueRef(5.5) == toValue(5.5)
        assert toValue(5.5) == toValueRef(5.5)
        assert toValueRef(5.5) == 5.5

      test "Should work for map":
        var s = @%(s: "s", i: 1, f: 1.1, b: true)
        assert s == @%(s: "s", i: 1, f: 1.1, b: true)
        assert not (s == @%(s: "lala"))

  test "Sequence Value":

    test "Should iterate in pairs":
      var s = @[1, 2, 3]
      for i, x in toValue(s):
        assert x == toValue(s[i])
      for i, x in toValueRef(s):
        assert x == toValue(s[i])


    test "Should iterate items":
      var s = @[1, 2, 3]
      var i = 0
      for x in toValue(s):
        assert x == toValue(s[i])
        i.inc()
      i = 0
      for x in toValueRef(s):
        assert x == toValue(s[i])
        i.inc()

    test "Should get/set with [], []=":
      var s = toValue([1, 2, 3])
      assert s[0][int] == 1
      s[0] = toValue(10)
      assert s[0][int] == 10
      s[0] = 15
      assert s[0][int] == 15

      var r = toValueRef([1, 2, 3])
      assert r[0][int] == 1
      r[0] = toValue(10)
      assert r[0][int] == 10
      r[0] = 15
      assert r[0][int] == 15

    test "Should .add()":
      var s = toValue([0, 1, 2])
      s.add(toValue(3))
      assert s[3][int] == 3
      s.add(4)
      assert s[4][int] == 4

      var r = toValueRef([0, 1, 2])
      r.add(toValue(3))
      assert r[3][int] == 3
      r.add(4)
      assert r[4][int] == 4

    test "Should build with newValueSeq()":
      var s = newValueSeq(1, "a", false)
      assert s[0][int] == 1
      assert s[1][string] == "a"
      assert s[2][bool] == false

    test "Should build with ValueSeq()":
      var s = ValueSeq(1, "a", false)
      assert s.isSeq()
      assert s[0][int] == 1
      assert s[1][string] == "a"
      assert s[2][bool] == false


  test("ValueMap"):

    test("Should set / get with `[]`"):
      var m = newValueMap()
      m["x"] = toValue(22)
      m["y"] = 33
      assert m["x"][int] == 22
      assert m["y"][int] == 33

    test("Should set / get Value with `.`"):
      var m = newValueMap()
      m.x = toValue(22)
      m.y = 33
      assert m.x[int] == 22
      assert m.y[int] == 33

    test("Should set / get with nested `.`"):
      var m = newValueMap()
      m.nested = newValueMap()

      m.nested.val = toValue(1)
      assert m.nested.val[int] == 1

      m.nested.key = "lala"
      assert m.nested.key[string] == "lala"

    test("Should set/get with nested `[]`"):
      var m = newValueMap()
      m["nested"] = newValueMap()

      m["nested"]["key"] = toValue(1)
      assert m["nested"]["key"][int] == 1

      m["nested"]["key"] = "lala"
      assert m["nested"]["key"][string] == "lala"

    test "Should auto-create nested maps":
      var m = newValueMap(autoNesting = true)
      m.nested.x.x = 1
      assert m.nested.x.x[int] == 1

      m.nested.x.y = "lala"
      assert m.nested.x.y[string] == "lala"

    test "Should create ValueMap from tuple with @%()":
      var m = @%(x: "str", i: 55)
      assert m.x == "str"
      assert m.i == 55

    test "Should .hasKey()":
      var m = @%(x: "str")
      assert m.hasKey("x")
      assert not m.hasKey("y")

    test "Should .keys()":
      var m = @%(x: "str", y: 1)
      var actualKeys = @["x", "y"]
      var keys: seq[string] = @[]
      for key in m.keys:
        keys.add(key)
      assert keys.toHashSet() == actualKeys.toHashSet()

    test "Should .getKeys()":
      var m = @%(x: "str", y: 1)
      var actualKeys = @["x", "y"]
      assert m.getKeys().toHashSet() == actualKeys.toHashSet()
    
    test "Should iterate over fieldpairs":
      var m = @%(x: "str", y: 1)
      for key, val in m.fieldPairs:
        assert val == m[key]

  test "JSON handling":

    test "Should parse json from string":
      var js = """{"str": "string", "intVal": 55, "floatVal": 1.115, "boolVal": true, "nested": {"nestedStr": "str", "arr": [1, 3, "str"]}}"""
      var map = fromJson(js)
      assert map.kind == valMap

      assert map.str == "string"

      assert map["intVal"] == 55

      assert map["floatVal"] == 1.115

      assert map["boolVal"] == true

      var nestedMap = map.nested
      assert nestedMap.kind == valMap

      assert nestedMap.nestedStr == "str"

      assert nestedMap.arr.isSeq

      var arr = nestedMap.arr
      assert arr.isSeq()
      assert arr.len() == 3
      assert arr[0] == 1
      assert arr[1] == 3
      assert arr[2] == "str"

    test "toJson":

      test "Should convert bool":
        assert toValue(true).toJson() == "true"
        assert toValue(false).toJson() == "false"

      test "Should convert char":
        assert toValue('x').toJson() == "\"x\""

      test "Should convert int":
        assert toValue(22).toJson() == "22"

      test "Should convert uint":
        assert toValue(22).toJson() == "22"

      test "Should convert float":
        assert toValue(22.22).toJson() == "22.22"

      test "Should convert string":
        assert toValue("test").toJson() == "\"test\""

      test "Should convert sequence":
        var s = toValue(@[1, 2])
        s.add("22")
        assert s.toJson() == "[1, 2, \"22\"]"

      test "Should convert map":
        var jsonObj = toMap((s: "str", i: 1, f: 10.11, b: true, nested: (ns: "str", ni: 5, na: @[1, 2, 3]))).toJson()
        assert json.`==`(json.parseJson(jsonObj), json.parseJson("""{"nested": {"ni": 5, "ns": "str", "na": [1, 2, 3]}, "f": 10.11, "i": 1, "s": "str", "b": true}"""))