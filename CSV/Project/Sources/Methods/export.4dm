//%attributes = {}
var $CSV : cs:C1710.CSV

$CSV:=cs:C1710.CSV.new()

/*
simple usage
*/

var $pTable1; $pTable2 : Pointer
$CSV.exportSelectionTo(Folder:C1567(fk desktop folder:K87:19).folder("csv-export"); $pTable1)

/*
advanced usage
*/

var $options : Object
$options:={noHeader: False:C215; noEOF: True:C214; noBOM: False:C215}
$CSV.exportSelectionTo(Folder:C1567(fk desktop folder:K87:19).folder("csv-export"); [$pTable1; $pTable2]; $options)

/*
utitity 
*/

$CSV.exportTo(Folder:C1567(fk desktop folder:K87:19).folder("csv-export"); $options)