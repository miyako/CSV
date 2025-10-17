# CSV
component to export records in CSV (namespace: `CSV`)

## exportSelectionTo(folder; tables{; options})

|parameter|type|description|
|-|-|-|
|folder|4D.Folder||
|tables|Variant|pointer to table, or a collection of pointers to tables|
|options|object|see below|

|option|type|description|
|-|-|-|
|noHeader|boolean|do not print field names in first line |
|noEOF|boolean|do not print `EOF` after last record|
|noBOM|boolean|do not print `BOM`|

* current selection must be created beforehand
* internally starts from first record
* table structure name is used as file name

## exportTo(folder{; options})

|parameter|type|description|
|-|-|-|
|folder|4D.Folder||
|options|object||

* internally calls `.exportSelectionTo` on all records of all tables

## points of interest

* `4D.FileHandle` is used internally (utf-8, with BOM)
* does not use ORDA
* exports generic method `.valueToCsv`
* RFC 4180 is applied on each field, with type specific rules:


```4d
var $CSV : cs.CSV

$CSV:=cs.CSV.new()
/*
	text
	the following values trigger quotation:
	ASCII 0x00–0x1F, DEL, doublequote, comma
*/
ASSERT("abc"=$CSV.valueToCsv("abc"))
ASSERT("\"a"+Char(0x007F)+"bc\""=$CSV.valueToCsv("a"+Char(0x007F)+"bc"))
ASSERT("\"a"+Char(0x000B)+"bc\""=$CSV.valueToCsv("a"+Char(0x000B)+"bc"))
ASSERT("\"a\rbc\""=$CSV.valueToCsv("a\rbc"))
ASSERT("\"a\"\"bc\""=$CSV.valueToCsv("a\"bc"))
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
ASSERT(""=$CSV.valueToCsv($pValue))
ASSERT("12:34:56"=$CSV.valueToCsv(?12:34:56?))
var $image : Picture
var $data : Blob
ASSERT(""=$CSV.valueToCsv($data))
ASSERT(""=$CSV.valueToCsv($image))
SET BLOB SIZE($data; 3)
$data{0}:=0x00AB
$data{1}:=0x00CD
$data{2}:=0x00EF
ASSERT("data:;base64,q83v"=$CSV.valueToCsv($data))
ASSERT(""=$CSV.valueToCsv(!00-00-00!))
ASSERT("2011-02-02"=$CSV.valueToCsv(!2011-02-02!))
ASSERT(""=$CSV.valueToCsv(Null))
ASSERT(""=$CSV.valueToCsv({}.a))
var $value : Variant
$value:=1
$pValue:=->$value
ASSERT("1"=$CSV.valueToCsv($pValue))
ASSERT("1"=$CSV.valueToCsv(->$pValue))
ASSERT("true"=$CSV.valueToCsv(True))
ASSERT("false"=$CSV.valueToCsv(False))
ASSERT("1"=$CSV.valueToCsv(0x0001))
ASSERT("3.1415926535898"=$CSV.valueToCsv(Pi))
ASSERT("0.33333333333333"=$CSV.valueToCsv(1/3))
ASSERT(""=$CSV.valueToCsv(1/0))  //INF
ASSERT(""=$CSV.valueToCsv(-1/0))  //-INF
ASSERT(""=$CSV.valueToCsv(Log(-1)))  //NaN
ASSERT(""=$CSV.valueToCsv
```
