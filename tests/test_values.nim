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
        check toValue(true).isBool()
        check toValue(true).getBool()
        check toValue(true).asBool()
        check toValue(true)[bool]

        check toValueRef(true).isBool()
        check toValueRef(true).getBool()
        check toValueRef(true).asBool()
        check toValueRef(true)[bool]

      test "Should work for char":
        check toValue('c').isChar()
        check toValue('c').getChar() == 'c'
        check toValue('c').asChar() == 'c'
        check toValue('c')[char] == 'c'

        check toValueRef('c').isChar()
        check toValueRef('c').getChar() == 'c'
        check toValueRef('c').asChar() == 'c'
        check toValueRef('c')[char] == 'c'

      test "Should work for int":
        check toValue(33'i8).isInt()
        check toValue(33'i16).isInt()
        check toValue(33'i32).isInt()
        check toValue(33'i64).isInt()
        check toValue(33).isInt()

        check toValue(33).getInt() == 33
        check toValue(33).asInt() == 33
        check toValue(33)[int8] == 33'i8
        check toValue(33)[int16] == 33'i16
        check toValue(33)[int32] == 33'i32
        check toValue(33)[int64] == 33'i64
        check toValue(33)[int] == 33

        check toValueRef(33).isInt()
        check toValueRef(33).getInt() == 33
        check toValueRef(33).asInt() == 33
        check toValueRef(33)[int] == 33

      test "Should work for uint":
        check toValue(33'u8).isUInt()
        check toValue(33'u16).isUInt()
        check toValue(33'u32).isUInt()
        check toValue(33'u64).isUInt()
        check toValue(33'u).isUInt()

        check toValue(33'u).getUInt() == 33'u
        check toValue(33'u).asUInt() == 33'u
        check toValue(33'u)[uint8] == 33'u8
        check toValue(33'u)[uint16] == 33'u16
        check toValue(33'u)[uint32] == 33'u32
        check toValue(33'u)[uint64] == 33'u64
        check toValue(33'u)[uint] == 33'u

        check toValueRef(33'u).isUInt()
        check toValueRef(33'u).getUInt() == 33'u
        check toValueRef(33'u).asUInt() == 33'u
        check toValueRef(33'u)[uint] == 33'u

      test "Should work for float":
        check toValue(33.33).isFloat()
        check toValue(33'f32).isFloat()
        check toValue(33'f64).isFloat()

        check toValue(33.33).getFloat() == 33.33
        check toValue(33.33).asFloat() == 33.33
        check toValue(33.33)[float32] == 33.33'f32
        check toValue(33.33)[float64] == 33.33'f64
        check toValue(33.33)[float] == 33.33

        check toValueRef(33.33).isFloat()
        check toValueRef(33.33).getFloat() == 33.33
        check toValueRef(33.33).asFloat() == 33.33
        check toValueRef(33.33)[float] == 33.33

      test "Should work for string":
        check toValue("string").isString()
        check toValue("string").getString() == "string"
        check toValue("string").asString() == "string"
        check toValue("string")[string] == "string"

        check toValueRef("string").isString()
        check toValueRef("string").getString() == "string"
        check toValueRef("string").asString() == "string"
        check toValueRef("string")[string] == "string"

      test "Should work for time":
        var t = times.getTime()
        var ti = times.local(t)
        check toValue(t).isTime()
        check toValue(t).getTime() == ti
        check toValue(t)[times.DateTime] == ti
        check toValue(t)[times.Time] == t

        check toValueRef(t).isTime()
        check toValueRef(t).getTime() == ti
        check toValueRef(t)[Time] == t

      test "Should work for sequence":
        var s = @[1, 2, 3]
        var vs = @[toValueRef(1), toValueRef(2), toValueRef(3)]
        check toValue(s).isSeq()
        check toValue(s).getSeq() == vs
        check toValue(s).asSeq(int) == s

        check toValueRef(s).isSeq()
        check toValueRef(s).getSeq() == vs
        check toValueRef(s).asSeq(int) == s

      test "Should work for array":
        var a = [1, 2, 3]
        var vs = @[toValueRef(1), toValueRef(2), toValueRef(3)]
        check toValue(a).isSeq()
        check toValue(a).getSeq() == vs

        check toValueRef(a).isSeq()
        check toValueRef(a).getSeq() == vs

      test "Should work for set":
        var a = {1, 2, 3}
        var vs = @[toValueRef(1), toValueRef(2), toValueRef(3)]
        check toValue(a).isSet()
        check toValue(a).getSeq() == vs

        check toValueRef(a).isSet()
        check toValueRef(a).getSeq() == vs

      test "Should work for map":
        var t = (s: "s", i: 1, f: 1.1)
        var m = toValueRef(t)
        check m.isMap()
        check m.s == "s"
        check m.i == 1
        check m.f == 1.1

    test "isZero()":
      test "Should work for int":
        check toValue(0).isZero()
        check not toValue(1).isZero()

        check toValueRef(0).isZero()
        check not toValueRef(1).isZero()

      test "Should work for uint":
        check toValue(0'u).isZero()
        check not toValue(1'u).isZero()

        check toValueRef(0'u).isZero()
        check not toValueRef(1'u).isZero()

      test "Should work for float":
        check toValue(0.0).isZero()
        check not toValue(1.1).isZero()

        check toValueRef(0.0).isZero()
        check not toValueRef(1.1).isZero()

      test "Should work for string":
        var s: string
        check toValue(s).isZero()
        check toValue("").isZero()
        check not toValue("a").isZero()

        check toValueRef(s).isZero()
        check toValueRef("").isZero()
        check not toValueRef("a").isZero()

    test ".len()":
      test "Should work for char":
        check toValue(' ').len() == 1
        check toValueRef(' ').len() == 1

      test "Should work for string":
        check toValue("abc").len() == 3
        check toValueRef("abc").len() == 3

      test "Should work for seq":
        check toValue(@[1, 2, 3]).len() == 3
        check toValueRef(@[1, 2, 3]).len() == 3

      test "Should work for set":
        check toValue({1, 2, 3}).len() == 3
        check toValueRef({1, 2, 3}).len() == 3

      test "Should work for map":
        check toValueRef((a: 1)).len() == 1

    test "`==`":
      test "Should work for bool":
        check toValue(true) == toValue(true)
        check toValue(true) == true

        check toValueRef(false) == toValueRef(false)
        check toValueRef(true) == toValue(true)
        check toValue(true) == toValueRef(true)
        check toValueRef(false) == false

      test "Should work for char":
        check toValue(' ') == toValue(' ')
        check toValue(' ') == ' '

        check toValueRef(' ') == toValueRef(' ')
        check toValueRef(' ') == toValue(' ')
        check toValue(' ') == toValueRef(' ')
        check toValueRef(' ') == ' '

      test "Should work for string":
        check toValue("a b c") == toValue("a b c")
        check toValue("a b c") == "a b c"

        check toValueRef("a b c") == toValueRef("a b c")
        check toValueRef("a b c") == toValue("a b c")
        check toValue("a b c") == toValueRef("a b c")
        check toValueRef("a b c") == "a b c"

      test "Should work for int":
        check toValue(5) == toValue(5)
        check toValue(5) == 5

        check toValueRef(5) == toValueRef(5)
        check toValueRef(5) == toValue(5)
        check toValue(5) == toValueRef(5)
        check toValueRef(5) == 5


      test "Should work for uint":
        check toValue(5'u) == toValue(5'u)
        check toValue(5'u) == 5'u

        check toValueRef(5'u) == toValueRef(5'u)
        check toValueRef(5'u) == toValue(5'u)
        check toValue(5'u) == toValueRef(5'u)
        check toValueRef(5'u) == 5'u

      test "Should work for float":
        check toValue(5.5) == toValue(5.5)
        check toValue(5.5) == 5.5

        check toValueRef(5.5) == toValueRef(5.5)
        check toValueRef(5.5) == toValue(5.5)
        check toValue(5.5) == toValueRef(5.5)
        check toValueRef(5.5) == 5.5

      test "Should work for sequence":
        var s = ValueSeq(1, 2, 3)
        check s == ValueSeq(1, 2, 3)
        check s == @[1, 2, 3]
        check s == [1, 2, 3]

        check toValueRef(5.5) == toValueRef(5.5)
        check toValueRef(5.5) == toValue(5.5)
        check toValue(5.5) == toValueRef(5.5)
        check toValueRef(5.5) == 5.5

      test "Should work for map":
        var s = @%(s: "s", i: 1, f: 1.1, b: true)
        check s == @%(s: "s", i: 1, f: 1.1, b: true)
        check not (s == @%(s: "lala"))

  test "Sequence Value":

    test "Should iterate in pairs":
      var s = @[1, 2, 3]
      for i, x in toValue(s):
        check x == toValue(s[i])
      for i, x in toValueRef(s):
        check x == toValue(s[i])


    test "Should iterate items":
      var s = @[1, 2, 3]
      var i = 0
      for x in toValue(s):
        check x == toValue(s[i])
        i.inc()
      i = 0
      for x in toValueRef(s):
        check x == toValue(s[i])
        i.inc()

    test "Should get/set with [], []=":
      var s = toValue([1, 2, 3])
      check s[0][int] == 1
      s[0] = toValue(10)
      check s[0][int] == 10
      s[0] = 15
      check s[0][int] == 15

      var r = toValueRef([1, 2, 3])
      check r[0][int] == 1
      r[0] = toValue(10)
      check r[0][int] == 10
      r[0] = 15
      check r[0][int] == 15

    test "Should .add()":
      var s = toValue([0, 1, 2])
      s.add(toValue(3))
      check s[3][int] == 3
      s.add(4)
      check s[4][int] == 4

      var r = toValueRef([0, 1, 2])
      r.add(toValue(3))
      check r[3][int] == 3
      r.add(4)
      check r[4][int] == 4

    test "Should build with newValueSeq()":
      var s = newValueSeq(1, "a", false)
      check s[0][int] == 1
      check s[1][string] == "a"
      check s[2][bool] == false

    test "Should build with ValueSeq()":
      var s = ValueSeq(1, "a", false)
      check s.isSeq()
      check s[0][int] == 1
      check s[1][string] == "a"
      check s[2][bool] == false


  test("ValueMap"):

    test("Should set / get with `[]`"):
      var m = newValueMap()
      m["x"] = toValue(22)
      m["y"] = 33
      check m["x"][int] == 22
      check m["y"][int] == 33

    test("Should set / get Value with `.`"):
      var m = newValueMap()
      m.x = toValue(22)
      m.y = 33
      check m.x[int] == 22
      check m.y[int] == 33

    test("Should set / get with nested `.`"):
      var m = newValueMap()
      m.nested = newValueMap()

      m.nested.val = toValue(1)
      check m.nested.val[int] == 1

      m.nested.key = "lala"
      check m.nested.key[string] == "lala"

    test("Should set/get with nested `[]`"):
      var m = newValueMap()
      m["nested"] = newValueMap()

      m["nested"]["key"] = toValue(1)
      check m["nested"]["key"][int] == 1

      m["nested"]["key"] = "lala"
      check m["nested"]["key"][string] == "lala"

    test "Should auto-create nested maps":
      var m = newValueMap(autoNesting = true)
      m.nested.x.x = 1
      check m.nested.x.x[int] == 1

      m.nested.x.y = "lala"
      check m.nested.x.y[string] == "lala"

    test "Should create ValueMap from tuple with @%()":
      var m = @%(x: "str", i: 55)
      check m.x == "str"
      check m.i == 55

    test "Should .hasKey()":
      var m = @%(x: "str")
      check m.hasKey("x")
      check not m.hasKey("y")

    test "Should .keys()":
      var m = @%(x: "str", y: 1)
      var actualKeys = @["x", "y"]
      var keys: seq[string] = @[]
      for key in m.keys:
        keys.add(key)
      check keys.toHashSet() == actualKeys.toHashSet()

    test "Should .getKeys()":
      var m = @%(x: "str", y: 1)
      var actualKeys = @["x", "y"]
      check m.getKeys().toHashSet() == actualKeys.toHashSet()
    
    test "Should iterate over fieldpairs":
      var m = @%(x: "str", y: 1)
      for key, val in m.fieldPairs:
        check val == m[key]

  test "JSON handling":

    test "Should parse json from string":
      var js = """{"str": "string", "intVal": 55, "floatVal": 1.115, "boolVal": true, "nested": {"nestedStr": "str", "arr": [1, 3, "str"]}}"""
      var map = fromJson(js)
      check map.kind == valMap

      check map.str == "string"

      check map["intVal"] == 55

      check map["floatVal"] == 1.115

      check map["boolVal"] == true

      var nestedMap = map.nested
      check nestedMap.kind == valMap

      check nestedMap.nestedStr == "str"

      check nestedMap.arr.isSeq

      var arr = nestedMap.arr
      check arr.isSeq()
      check arr.len() == 3
      check arr[0] == 1
      check arr[1] == 3
      check arr[2] == "str"

    test "toJson":

      test "Should convert bool":
        check toValue(true).toJson() == "true"
        check toValue(false).toJson() == "false"

      test "Should convert char":
        check toValue('x').toJson() == "\"x\""

      test "Should convert int":
        check toValue(22).toJson() == "22"

      test "Should convert uint":
        check toValue(22).toJson() == "22"

      test "Should convert float":
        check toValue(22.22).toJson() == "22.22"

      test "Should convert string":
        check toValue("test").toJson() == "\"test\""

      test "Should convert sequence":
        var s = toValue(@[1, 2])
        s.add("22")
        check s.toJson() == "[1, 2, \"22\"]"

      test "Should convert map":
        var jsonObj = toMap((s: "str", i: 1, f: 10.11, b: true, nested: (ns: "str", ni: 5, na: @[1, 2, 3]))).toJson()
        check json.`==`(json.parseJson(jsonObj), json.parseJson("""{"nested": {"ni": 5, "ns": "str", "na": [1, 2, 3]}, "f": 10.11, "i": 1, "s": "str", "b": true}"""))
