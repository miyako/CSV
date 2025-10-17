//%attributes = {}
var $CSV : cs:C1710.CSV

$CSV:=cs:C1710.CSV.new()


ALL RECORDS:C47([Table_1:1])
ALL RECORDS:C47([Table_2:2])

$pTable1:=->[Table_1:1]
$pTable2:=->[Table_2:2]

/*
simple usage
*/

$CSV.exportSelectionTo(Folder:C1567(fk desktop folder:K87:19).folder("csv-export"); $pTable)

/*
advanced usage
*/

$options:={noHeader: False:C215; noEOF: True:C214; noBOM: False:C215}
$CSV.exportSelectionTo(Folder:C1567(fk desktop folder:K87:19).folder("csv-export"); [$pTable1; $pTable2]; $options)

/*
utitity 
*/

$CSV.exportTo(Folder:C1567(fk desktop folder:K87:19).folder("csv-export"); $options)