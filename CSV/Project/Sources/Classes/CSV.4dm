property charset : Text
property breakModeWrite : Text
property delimiter : Text
property mode : Text
property BOM : 4D:C1709.Blob
property extension : Text

Class constructor
/*
4D.FileHandle options
*/
	This:C1470.breakModeWrite:="crlf"
	This:C1470.charset:="utf-8"
	This:C1470.mode:="write"
/*
CSV options
*/
	This:C1470.delimiter:=","
	This:C1470.extension:=".csv"
/*
utf-8 options
*/
	SET BLOB SIZE:C606($BOM; 3)
	$BOM{0}:=0x00EF
	$BOM{1}:=0x00BB
	$BOM{2}:=0x00BF
	This:C1470.BOM:=$BOM
	
Function writeBOM($fileHandle : 4D:C1709.FileHandle)
	
	If (Not:C34(OB Instance of:C1731($fileHandle; 4D:C1709.FileHandle))) || ($fileHandle.mode="read")
		return 
	End if 
	
	$fileHandle.writeBlob(This:C1470.BOM)
	
Function isTablePointer($pointer : Pointer) : Boolean
	
	If (Is a variable:C294($pointer)) || (Is nil pointer:C315($pointer))
		return False:C215
	End if 
	
	var $variableName : Text
	var $tableNumber; $fieldNumber : Integer
	RESOLVE POINTER:C394($pointer; $variableName; $tableNumber; $fieldNumber)
	
	return ($tableNumber#0) && ($fieldNumber=0)
	
Function exportSelectionTo($folder : 4D:C1709.Folder; $tables : Variant; $options : Object)
	
	var $noHeader : Boolean
	var $noEOF : Boolean
	var $noBOM : Boolean
	
	If ($options#Null:C1517)
		$noHeader:=Bool:C1537($options.noHeader)
		$noEOF:=Bool:C1537($options.noEOF)
		$noBOM:=Bool:C1537($options.noBOM)
	End if 
	
	var $valueType : Integer
	$valueType:=Value type:C1509($tables)
	Case of 
		: ($valueType=Is collection:K8:32)
		: ($valueType=Is pointer:K8:14)
			$tables:=[$tables]
		Else 
			return 
	End case 
	
	If (Not:C34(OB Instance of:C1731($folder; 4D:C1709.Folder)))
		return 
	End if 
	
	$folder.create()
	
	var $table : Variant
	var $tableFile : 4D:C1709.File
	var $tableFileHandle : 4D:C1709.FileHandle
	var $writtenCol; $writtenRow : Boolean
	var $t; $f : Integer
	var $line : Collection
	var $EOL : Text
	var $written : Boolean
	
	Case of 
		: (This:C1470.breakModeWrite="cr")
			$EOL:="\r"
		: (This:C1470.breakModeWrite="lf")
			$EOL:="\n"
		: (This:C1470.breakModeWrite="crlf")
			$EOL:="\r\n"
		: (This:C1470.breakModeWrite="native")
			$EOL:=Is macOS:C1572 ? "\n" : "\r\n"
	End case 
	
	For each ($table; $tables)
		
		If (Value type:C1509($table)#Is pointer:K8:14) || (Not:C34(This:C1470.isTablePointer($table)))
			continue
		End if 
		
		$t:=Table:C252($table)
		//make sure we have full path
		$folder:=Folder:C1567($folder.platformPath; fk platform path:K87:2)
		$tableFile:=$folder.file(Table name:C256($t)+This:C1470.extension)
		
		Case of 
			: (Test path name:C476($tableFile.platformPath)=Is a document:K24:1)
				$tableFile.delete()
			: (Test path name:C476($tableFile.platformPath)=Is a folder:K24:2)
				Folder:C1567($tableFile.path).delete(Delete with contents:K24:24)
		End case 
		
		$tableFileHandle:=$tableFile.open(This:C1470)
		
		If (Not:C34($noBOM))
			This:C1470.writeBOM($tableFileHandle)
		End if 
		
		FIRST RECORD:C50($table->)
		
		$written:=False:C215
		var $headers : Collection
		$headers:=[]
		
		If (Not:C34($noHeader))
			For ($f; 1; Last field number:C255($t))
				If (Not:C34(Is field number valid:C1000($t; $f)))
					continue
				End if 
				$headers.push(This:C1470.valueToCsv(Field name:C257(Field:C253($t; $f))))
			End for 
			//the header line will always have an EOL regardless of noEOL
			$tableFileHandle.writeLine($headers.join(This:C1470.delimiter))
		End if 
		
		Repeat 
			If ($written)
				$tableFileHandle.writeText($EOL)
			End if 
			$line:=[]
			For ($f; 1; Last field number:C255($t))
				If (Not:C34(Is field number valid:C1000($t; $f)))
					continue
				End if 
				$line.push(This:C1470.valueToCsv(Field:C253($t; $f)))
				$written:=True:C214
			End for 
			$tableFileHandle.writeText($line.join(This:C1470.delimiter))
			NEXT RECORD:C51($table->)
		Until (End selection:C36($table->))
		If (Not:C34($noEOF)) && ($written)
			$tableFileHandle.writeText($EOL)
		End if 
		$tableFileHandle:=Null:C1517
	End for each 
	
Function exportTo($folder : 4D:C1709.Folder; $options : Object)
	
	var $tables : Collection
	$tables:=[]
	var $t : Integer
	var $pTable : Pointer
	For ($t; 1; Last table number:C254)
		If (Not:C34(Is table number valid:C999($t)))
			continue
		End if 
		$pTable:=Table:C252($t)
		$tables.push($pTable)
		READ ONLY:C145($pTable->)
		ALL RECORDS:C47($pTable->)
	End for 
	
	This:C1470.exportSelectionTo($folder; $tables; $options)
	
Function valueToCsv($value : Variant) : Text
	
	var $valueType:=Value type:C1509($value)
	
	Case of 
		: ($valueType=Is boolean:K8:9)
			return $value ? "true" : "false"
		: ($valueType=Is date:K8:7)
			Case of 
				: ($value=!00-00-00!)
					return 
				Else 
					return Substring:C12(String:C10($value; ISO date:K1:8); 1; 10)
			End case 
		: ($valueType=Is longint:K8:6)
			return String:C10($value; "&xml")
		: ($valueType=Is real:K8:4)
			$value:=String:C10($value; "&xml")
			Case of 
				: ($value="INF")
					return 
				: ($value="-INF")
					return 
				: ($value="NaN")
					return 
				Else 
					return $value
			End case 
		: ($valueType=Is text:K8:3)
			Case of 
				: (Match regex:C1019("[,\"\\u0000-\\u001f\\u007f]"; $value; 1))
					return "\""+Replace string:C233($value; "\""; "\"\""; *)+"\""
				Else 
					return $value
			End case 
		: ($valueType=Is time:K8:8)
			return String:C10($value)
		: ($valueType=Is undefined:K8:13)
			return 
		: ($valueType=Is null:K8:31)
			return 
		: ($valueType=Is BLOB:K8:12)
			Case of 
				: (BLOB size:C605($value)=0)
					return 
				Else 
					var $b64 : Text
					BASE64 ENCODE:C895($value; $b64)
					return "data:;base64,"+$b64
			End case 
		: ($valueType=Is picture:K8:10)
			var $data : Blob
			PICTURE TO BLOB:C692($value; $data; "image/png")
			return This:C1470.valueToCsv($data)
		: ($valueType=Is pointer:K8:14)
			Case of 
				: (Is nil pointer:C315($value))
					return 
				Else 
					return This:C1470.valueToCsv($value->)
			End case 
		: ($valueType=Is collection:K8:32) || ($valueType=Is object:K8:27)
			return This:C1470.valueToCsv(JSON Stringify:C1217($value))
		Else 
			return 
	End case 