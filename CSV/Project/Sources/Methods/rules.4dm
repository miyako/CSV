//%attributes = {"invisible":true,"preemptive":"capable"}
var $CSV : cs:C1710.CSV

$CSV:=cs:C1710.CSV.new()
/*
text
the following values trigger quotation:
ASCII 0x00–0x1F, DEL, doublequote, comma
*/
ASSERT:C1129("abc"=$CSV.valueToCsv("abc"))
ASSERT:C1129("\"a"+Char:C90(0x007F)+"bc\""=$CSV.valueToCsv("a"+Char:C90(0x007F)+"bc"))
ASSERT:C1129("\"a"+Char:C90(0x000B)+"bc\""=$CSV.valueToCsv("a"+Char:C90(0x000B)+"bc"))
ASSERT:C1129("\"a\rbc\""=$CSV.valueToCsv("a\rbc"))
ASSERT:C1129("\"a\"\"bc\""=$CSV.valueToCsv("a\"bc"))
/*
non-text
the following value are considered empty
null, undefined, INF, -INF, NaN, !00-00-00!, empty blob, empty picture, nil pointer
type specific rules
- numeric
  decimal point is always period (&xml)
- pointer
  are derefenced until they return a value
- BLOB
  data uri unless empry
- picture
  image/png->BLOB
- object, collection
  JSON Stringify->text
*/
var $pValue : Pointer
ASSERT:C1129(""=$CSV.valueToCsv($pValue))
ASSERT:C1129("12:34:56"=$CSV.valueToCsv(?12:34:56?))
var $image : Picture
var $data : Blob
ASSERT:C1129(""=$CSV.valueToCsv($data))
ASSERT:C1129(""=$CSV.valueToCsv($image))
SET BLOB SIZE:C606($data; 3)
$data{0}:=0x00AB
$data{1}:=0x00CD
$data{2}:=0x00EF
ASSERT:C1129("data:;base64,q83v"=$CSV.valueToCsv($data))
ASSERT:C1129(""=$CSV.valueToCsv(!00-00-00!))
ASSERT:C1129("2011-02-02"=$CSV.valueToCsv(!2011-02-02!))
ASSERT:C1129(""=$CSV.valueToCsv(Null:C1517))
ASSERT:C1129(""=$CSV.valueToCsv({}.a))
var $value : Variant
$value:=1
$pValue:=->$value
ASSERT:C1129("1"=$CSV.valueToCsv($pValue))
ASSERT:C1129("1"=$CSV.valueToCsv(->$pValue))
ASSERT:C1129("true"=$CSV.valueToCsv(True:C214))
ASSERT:C1129("false"=$CSV.valueToCsv(False:C215))
ASSERT:C1129("1"=$CSV.valueToCsv(0x0001))
ASSERT:C1129("3.1415926535898"=$CSV.valueToCsv(Pi:K30:1))
ASSERT:C1129("0.33333333333333"=$CSV.valueToCsv(1/3))
ASSERT:C1129(""=$CSV.valueToCsv(1/0))  //INF
ASSERT:C1129(""=$CSV.valueToCsv(-1/0))  //-INF
ASSERT:C1129(""=$CSV.valueToCsv(Log:C22(-1)))  //NaN
ASSERT:C1129(""=$CSV.valueToCsv(Pi:K30:1^MAXLONG:K35:2))  //INF