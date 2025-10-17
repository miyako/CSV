# CSV
component to export records in CSV (namespace: `CSV`)

## exportSelectionTo(folder; tables)

|parameter|type|description|
|-|-|-|
|folder|4D.Folder||
|tables|Variant|pointer to table, or a collection of pointers to tables|

* current selection must be created beforehand
* internally starts from first record
* table structure name is used as file name

## exportTo(folder)

|parameter|type|description|
|-|-|-|
|folder|4D.Folder||

* internally calls `.exportSelectionTo` on all records of all tables
